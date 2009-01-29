From: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
Subject: Re: [PATCH] Fix infinite retry loop in IP-Config
Date: Thu, 29 Jan 2009 16:33:35 +0100
Message-ID: <4981CC4F.6050609@alcatel-lucent.fr>
References: <20090128105220.GB4190@ff.dom.local> <49804AAF.7020702@alcatel-lucent.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smail4.alcatel.fr ([62.23.212.167]:56627 "EHLO
	smail4.alcatel.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758313AbZA2PfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 10:35:24 -0500
Received: from bsf.alcatel.fr (mail205.sxb.bsf.alcatel.fr [155.132.205.115])
	by smail4.alcatel.fr (ALCANET/NETFR) with ESMTP id n0TFZKLs019197
	for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 16:35:20 +0100
Received: from mail (mail-bsf-alcatel-fr.sxb.bsf.alcatel.fr [155.132.205.91])
	by bsf.alcatel.fr (8.8.8p2+Sun/8.9.3) with ESMTP id QAA12495
	for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 16:35:20 +0100 (MET)
Received: from [172.25.51.190] (frilld0f09516 [172.25.51.190])
	by mail (8.8.8p2+Sun/) with ESMTP id QAA12491
	for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 16:35:20 +0100 (MET)
In-Reply-To: <49804AAF.7020702@alcatel-lucent.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin ZORES a =E9crit :
> Jarek Poplawski a =E9crit :
>> On 28-01-2009 10:07, Benjamin ZORES wrote:
>> =20
>>> Hi,
>>>
>>> The attached patch fixes some bug with ip-config max retry number.
>>> In ip_auto_config(), kernel tries to retrieve IP configuration fore=
ver
>>> in case of NFS root and some specific amount of time otherwise.
>>>
>>> The problem is that, in case of error, the code jump to the=20
>>> try_try_again
>>> goto statement, that reassigns the retry number counter, which=20
>>> obviously
>>> leads to an infinite loop if IP config fails.
>>>
>>> The attached patch corrects this behavior.
>>> Hope one can push it to mainstream kernel tree.
>>>
>>> Ben
>>>
>>> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
>>> index 42a0f3d..4911b81 100644
>>> --- a/net/ipv4/ipconfig.c
>>> +++ b/net/ipv4/ipconfig.c
>>> @@ -1268,6 +1268,7 @@ __be32 __init root_nfs_parse_addr(char *name)
>>>  static int __init ip_auto_config(void)
>>>  {
>>>      __be32 addr;
>>> +     int retries =3D CONF_OPEN_RETRIES;
>>>    =20
>> =20
>> Doesn't it need "#ifdef IPCONFIG_DYNAMIC" to prevent a compiler
>> warning? I guess you could add a "Signed-off-by:" line BTW.
>>  =20
> You're perfectly right about this.
> Attached an updated version of the patch.
Any chance of having it merged ?

Ben
