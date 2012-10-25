From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Thu, 25 Oct 2012 15:52:10 -0700
Message-ID: <CAK3+h2zLGGA2w38mRwpf5Ww+d8ZdtESp1zix82OZODG7o=Rsbg@mail.gmail.com>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
	<1351204948.6537.263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:41655 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab2JYWwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:52:11 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1728254iag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 15:52:10 -0700 (PDT)
In-Reply-To: <1351204948.6537.263.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 3:42 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-10-25 at 15:27 -0700, Vincent Li wrote:
>> Hi,
>>
>> this sounds crazy, we have a weird situation that an unknown tcp
>> implementation not putting tcp MSS option in the SYN/ACK which caused
>> us some issue. I am tasked to mimic the unknown tcp immplementation on
>> not sending MSS in tcp SYN/ACK, I am wondering if I can achieve that
>> by modifying linux kernel tcp code,  there is socket option
>> TCP_MAXSEG, but that seems only affecting the size of MSS, not
>> removing the MSS option. do you have any pointer on how to do that in
>> kernel tcp code?
>
> You'll have to patch the code.
>
> Or else, you could add a new feature to net/netfilter/xt_TCPMSS.c
>
> (We already have
>
> #define XT_TCPMSS_CLAMP_PMTU 0xffff
>
> You could add
>
> #define XT_TCPMSS_REMOVE 0xfffe
>
> and replace MSS option by NOP
>
>
>
thanks for the reply, I did a quick look at the code, as a quick dirty
hack, can I change the

 699 /* Set up TCP options for SYN-ACKs. */
 700 static unsigned int tcp_synack_options(struct sock *sk,
 701                                    struct request_sock *req,
 702                                    unsigned int mss, struct sk_buff *skb,
 703                                    struct tcp_out_options *opts,
 704                                    struct tcp_md5sig_key **md5,
 705                                    struct tcp_extend_values *xvp)
 706 {

..................
 730         /* We always send an MSS option. */
 731         opts->mss = mss; <---------here set opts->mss = 0 ?

would that work?
