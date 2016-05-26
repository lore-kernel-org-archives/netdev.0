From: Tom Herbert <tom@herbertland.com>
Subject: Re: IPv6 extension header privileges
Date: Thu, 26 May 2016 11:42:42 -0700
Message-ID: <CALx6S3580cJPWskNYD_xYbveXTdOzPVB8axXh471jDVzm94PhA@mail.gmail.com>
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
	<CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37431 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbcEZSmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 14:42:43 -0400
Received: by mail-ig0-f178.google.com with SMTP id l10so52453265igk.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 11:42:43 -0700 (PDT)
In-Reply-To: <CALx6S358LkPTz9kzWDuveZgDFjaL7AbgwgcVLP4iyC6Bvd3yBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2016 at 11:11 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Sun, May 22, 2016 at 4:56 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
>>
>>> > Tom Herbert wrote:
>>> >>>>> If you don't mind I'll change this to make specific options are
>>> >>>>> privileged and not all hbh and destopt. There is talk in IETF about
>>> >>>>> reinventing IP extensibility within UDP since the kernel APIs don't
>>> >>>>> allow setting EH. I would like to avoid that :-)
>>
>>> On 21.05.2016 19:46, Sowmini Varadhan wrote:
>>> > Do you mean this
>>> >   http://www.ietf.org/mail-archive/web/spud/current/msg00365.html
>>
>> On (05/22/16 03:08), Hannes Frederic Sowa wrote:
>>> Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
>>> extension headers mentioned but haven't grasped why they deem necessary.
>>
>> Tom should clarify what he meant, but perhaps he was referring to other
>> threads discussing v6 EH. In any case, I dont think the way least-privileges
>> for EH are implemented in an OS is directly relevant or causational for
>> whether or not the kernel should be bypassed - looks like there are a lot
>> of other drafts floating around, arguing for implementing various tcp/ip
>> protocols in uspace and beyond, motivated by various reasons.
>>
> It's a deployment conundrum. Suppose tomorrow that IANA registers some
> new hpb option that would be useful to the network, but is of no
> interest to the kernel other than it needs to be set in packets when
> the user requests it. In the white list model, there is no problem
> getting support for such a thing into the upstream kernel, the time
> frame for that is one release cycle. Neither is there any problem
> updating the apps to set the option, for instance we can update FB app
> to do this within a week. The problem is that getting something into
> the kernel does not make it useful, the kernel needs to actually be
> deployed which is mostly out of our control (for those of us who don't
> own the client platform). So get the options deployed on clients
> (particularly Android), this takes much, much longer. And if the
> feature requires explicit action do be enabled, like turning a sysctl,
> it is going to take even longer possibly an indeterminate amount of
> time to ever get enabled.
>
Thinking about this some more, the per option white list is a better
approach. If we allow an open ended mechanism for applications to
signal the network with arbitrary data (like user specified hbp
options would be), then use of that mechanism will inevitably
exploited by some authorities to force user to hand over private data
about their communications. It's better to not build in back doors to
security...

Tom

> Tom
>
>> Moving back to the topic here:
>>
>>> > Hannes Frederic Sowa wrote:
>>> >>>> A white list of certain registered IPv6 IANA-options for non-priv whould
>>
>>> On 21.05.2016 19:46, Sowmini Varadhan wrote:
>>> > Problem is that APIs are not IANA'ed.
>>> > Even RFC 3542 is just Informationaal.
>>> >
>>> > And even the classic socket API's that come down from BSD are not
>>> > ietf'ed or iana'ed.
>>
>> On (05/22/16 03:08), Hannes Frederic Sowa wrote:
>>> Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
>>> I think I don't completely understand this. IANA is numbering registry
>>> and if we have the proper option number allocated we can make sensible
>>> decisions and put options on the white list or provide a more complete
>>> sensible implementation of the specification in the kernel.
>>
>> IANA registers internet protocol (and related) numbers. so, e.g.,
>> So, for example, IP_TOS value is not really documented in iana,
>> and it ends up being 1 on linux, 3 on freebsd.  Or, to take another example,
>> IP_PKTINFO is "8" on linux, 0x1a on solaris and 25 in netbsd.
>>
>> But TOS, and the various code-points (which actually go out
>> in the packet, and are needed for proper interop in the network)
>> are documented in iana/ietf etc.
>>
>>> E.g. if an option for encapsulation is going to be specified, normal
>>> users should not be able to set those, like with CALIPSO or some VNI
>>> inside hop-by-hop options. That should probably be controlled by a
>>> routing table or a flow matching subsystem, in the kernel.
>>
>> sure, I completely agree with that. And I strongly suspect that's why
>> rfc3542 puts down a wildcard "may" - so that some options may be privileged,
>> others not. Which options are "privileged" (and even the definition
>> of "privileged") are entirely up to the OS implementation. (and even *how*
>> least priviliges/RBAC are implemented, can vary from OS to OS).
>>
>>> I think it is also in favor of the IETF to get those numbers specified
>>> and allocated in a proper way, otherwise security won't be manageable at
>>> all any more.
>>
>> see above.. Even rfc793 actually does not talk about POSIX APIs
>> but speaks in generalities, since the focus is on what goes on the wire.
>> In theory an implementation of a tcp/ip stack does not even have
>> to use the POSIX socket api, thus how can iana/ietf manadate
>> specific socket options and numbers, or the rbac model that they
>> should use?
>>
>> but that should not stop the linux kernel (or other OS) from trying
>> to figure out the granularity of the rbac for these options and documenting
>> them in some helpful way for apps.
>>
>> --Sowmini
