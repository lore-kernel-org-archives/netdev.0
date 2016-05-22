From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Sun, 22 May 2016 14:13:29 +0200
Message-ID: <c200b935-418e-7436-c17d-9e152fbdc920@stressinduktion.org>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
 <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
 <20160521174438.GA27990@oracle.com>
 <82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
 <20160522115605.GA30516@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54156 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752205AbcEVMNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 08:13:33 -0400
In-Reply-To: <20160522115605.GA30516@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.05.2016 13:56, Sowmini Varadhan wrote:
> 
>>> Tom Herbert wrote:
>>>>>>> If you don't mind I'll change this to make specific options are
>>>>>>> privileged and not all hbh and destopt. There is talk in IETF about
>>>>>>> reinventing IP extensibility within UDP since the kernel APIs don't
>>>>>>> allow setting EH. I would like to avoid that :-)
> 
>> On 21.05.2016 19:46, Sowmini Varadhan wrote:
>>> Do you mean this
>>>   http://www.ietf.org/mail-archive/web/spud/current/msg00365.html
> 
> On (05/22/16 03:08), Hannes Frederic Sowa wrote:
>> Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
>> extension headers mentioned but haven't grasped why they deem necessary.
> 
> Tom should clarify what he meant, but perhaps he was referring to other
> threads discussing v6 EH. In any case, I dont think the way least-privileges
> for EH are implemented in an OS is directly relevant or causational for
> whether or not the kernel should be bypassed - looks like there are a lot 
> of other drafts floating around, arguing for implementing various tcp/ip
> protocols in uspace and beyond, motivated by various reasons.
> 
> Moving back to the topic here:
> 
>>> Hannes Frederic Sowa wrote:
>>>>>> A white list of certain registered IPv6 IANA-options for non-priv whould
> 
>> On 21.05.2016 19:46, Sowmini Varadhan wrote:
>>> Problem is that APIs are not IANA'ed. 
>>> Even RFC 3542 is just Informationaal. 
>>>
>>> And even the classic socket API's that come down from BSD are not 
>>> ietf'ed or iana'ed.
> 
> On (05/22/16 03:08), Hannes Frederic Sowa wrote:
>> Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
>> I think I don't completely understand this. IANA is numbering registry
>> and if we have the proper option number allocated we can make sensible
>> decisions and put options on the white list or provide a more complete
>> sensible implementation of the specification in the kernel.
> 
> IANA registers internet protocol (and related) numbers. so, e.g., 
> So, for example, IP_TOS value is not really documented in iana,
> and it ends up being 1 on linux, 3 on freebsd.  Or, to take another example,
> IP_PKTINFO is "8" on linux, 0x1a on solaris and 25 in netbsd.  

Our setsockopts take the option numbers verbatim as they appear on the
wire (struct ipv6_opt_hdr). Thus we only need the numbers like
registered in the ipv6 parameter registry. API doesn't need to change
besides the privilege check. This is enough for Linux.

> but that should not stop the linux kernel (or other OS) from trying 
> to figure out the granularity of the rbac for these options and documenting 
> them in some helpful way for apps.

Just by knowing which option is interpreted in which way, we can do the
decision. I don't want to standardize APIs at all.

Bye,
Hannes
