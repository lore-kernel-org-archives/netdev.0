From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC 2/2] TCP: Add TCP-AO support
Date: Sat, 19 Jul 2008 12:07:21 +0900 (JST)
Message-ID: <20080719.120721.88812679.yoshfuji@linux-ipv6.org>
References: <396556a20807181816qdb50221nc0aa259d3fb3395d@mail.gmail.com>
	<20080719.102838.76205933.yoshfuji@linux-ipv6.org>
	<396556a20807181922t32c05b86l335de10bd1106ab2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32801 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbYGSDHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 23:07:24 -0400
In-Reply-To: <396556a20807181922t32c05b86l335de10bd1106ab2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <396556a20807181922t32c05b86l335de10bd1106ab2@mail.gmail.com> (at Fri, 18 Jul 2008 19:22:35 -0700), "Adam Langley" <agl@imperialviolet.org> says:

> On Fri, Jul 18, 2008 at 6:28 PM, YOSHIFUJI Hideaki / 吉藤英明
> <yoshfuji@linux-ipv6.org> wrote:
> > Again, is it okay to add/del one key per each operation?
> 
> Yes, I believe so. (At least I can't think of a situation where it isn't)
> 
> > If yes, we do not need to change current API too much.
> 
> I think, if we're only supporting two keys, the API in the patch (save
> making the flags wider etc) is good.
> 
> If the concenous is that we need to support > 2 keys per address, then
> I'll have a think.

If we can do incremental approach, even if we suppor upto 2 keys,
I'd suggest something like this:

struct tcp_auth {
       struct sockaddr_storage tcpa_addr;
       __u8                    tcpa_keyid
       __u8                    tcpa_algo;
       __u16                   tcpa_keylen;
       __u32		       tcpa_flags;
       __u8		       tcpa_key[TCP_AUTHOPT_MAXKEYLEN];
};

(I think you can get my idea, anyway.)

And it would be better to have another option such as TCP_AUTHOPT or such
for property for all keys.

--yoshfuji
