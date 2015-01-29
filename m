From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Thu, 29 Jan 2015 15:14:46 +0100
Message-ID: <54CA4056.6030301@6wind.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com> <54CA0B9F.8080104@6wind.com> <063D6719AE5E284EB5DD2968C1650D6D1CAD56B0@AcuExch.aculab.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>, Fan Du <fan.du@intel.com>,
	"steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33391 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbbA2OOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 09:14:49 -0500
Received: by mail-wi0-f171.google.com with SMTP id l15so26789729wiw.4
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 06:14:48 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD56B0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/01/2015 14:56, David Laight a =C3=A9crit :
> From: Nicolas Dichtel
>> Le 27/01/2015 10:00, Fan Du a crit :
>>> structure like xfrm_usersa_info or xfrm_userpolicy_info
>>> has different sizeof when compiled as 32bits and 64bits
>>> due to not appending pack attribute in their definition.
>>> This will result in broken SA and SP information when user
>>> trying to configure them through netlink interface.
>>>
>>> Inform user land about this situation instead of keeping
>>> silent, the upper test scripts would behave accordingly.
>>>
>>> Quotes from: http://marc.info/?l=3Dlinux-netdev&m=3D142226348715503=
&w=3D2
>>>>
>>>> Before a clean solution show up, I think it's better to warn user =
in some way
>>>> like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, man=
y people
>>>> who stuck there will always spend time and try to fix this issue i=
n whatever way.
>>>
>>> Yes, this is the first thing we should do. I'm willing to accept a =
patch
>>>
>>> Signed-off-by: Fan Du <fan.du@intel.com>
>> A way to solve this problem was to provide to userland a xfrm compat=
 header
>> file, which match the ABI of the kernel. Something like:
>>
>> #include <linux/xfrm.h>
>>
>> #define xfrm_usersa_info xfrm_usersa_info_64
>> #define xfrm_usersa_info_compat xfrm_usersa_info
>> struct xfrm_usersa_info_compat {
>> 	struct xfrm_selector		sel;
>> 	struct xfrm_id			id;
>> 	xfrm_address_t			saddr;
>> 	struct xfrm_lifetime_cfg	lft;
>> 	struct xfrm_lifetime_cur	curlft;
>> 	struct xfrm_stats		stats;
>> 	__u32				seq;
>> 	__u32				reqid;
>> 	__u16				family;
>> 	__u8				mode;
>> 	__u8				replay_window;
>> 	__u8				flags;
>> 	__u8				hole1;
>> 	__u32				hole2;
>> };
>>
>> The point I try to make is that patching userland apps allows to use=
 xfrm on a
>> 32bits userland / 64bits kernel.
>>
>> If I understand well your patch, it will not be possible anymore, al=
l messages
>> will be rejected. And this may break existing apps.
>
> Probably OTT in this case.
> IIRC the only actual difference if the 'end padding'.
> So the wrapper need only ensure the copyin/out isn't too long.
It was just an example for one struct. Some other structures need to be
patched (eg struct xfrm_userspi_info uses struct xfrm_usersa_info).
And some attributes may follow this structure which will be padded to
be aligned.
The point was more to show that the existing interface can be used (and=
 cannot
be used after the patch).

Regards,
Nicolas
