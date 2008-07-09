From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: setsockopt()
Date: Tue, 8 Jul 2008 17:07:45 -0700
Message-ID: <1e41a3230807081707rcdb7ed6o91ff6e7d00aaa70b@mail.gmail.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>
	 <48728B09.1050801@citi.umich.edu>
	 <20080707.144912.76654646.davem@davemloft.net>
	 <20080708201217.GA16119@citi.umich.edu>
	 <1e41a3230807081454n6460778u8cb889600d07421e@mail.gmail.com>
	 <20080708235125.GA11699@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aglo@citi.umich.edu, shemminger@vyatta.com,
	bfields@fieldses.org
To: "Jim Rees" <rees@umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:24228 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbYGIAHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 20:07:48 -0400
Received: by an-out-0708.google.com with SMTP id d40so557744and.103
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2008 17:07:45 -0700 (PDT)
In-Reply-To: <20080708235125.GA11699@citi.umich.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 8, 2008 at 4:51 PM, Jim Rees <rees@umich.edu> wrote:
> John Heffner wrote:
>
>  I actually like your idea for a "soft"
>  SO_SNDBUF -- ask the kernel for at least that much, but let it
>  autotune higher if needed.  This is almost trivial to implement --
>  it's the same as SO_SNDBUF but don't set the sock sndbuf lock.
>
> Which brings me to another issue.  The nfs server doesn't call
> sock_setsockopt(), it diddles sk_sndbuf and sk_rcvbuf directly, so as to get
> around the max socket buf limit.  I don't like this.  If this is a legit
> thing to do, there should be an api.
>
> I'm thinking we need a sock_set_min_bufsize(), where the values passed in
> are minimums, subject to autotuning, and maybe are not limited by the max.
> It would, as you say, just set sk_sndbuf and sk_rcvbuf without setting the
> corresponding flags SOCK_SNDBUF_LOCK and SOCK_RCVBUF_LOCK.
>
> Would this do the trick, or is there a danger that autotuning would reduce
> the buffer sizes below the given minimum?  If so, we might need
> sk_min_rcvbuf or something like that.


TCP buffer sizes will only be pulled back if the system runs into the
global tcp memory limits (sysctl_tcp_mem).  I think this is correct
behavior regardless of the requested value.

  -John
