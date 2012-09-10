From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] Take care of xfrm policy when checking dst
 entries
Date: Mon, 10 Sep 2012 16:38:02 +0200
Message-ID: <504DFB4A.8080708@6wind.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net> <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com> <504DFA97.7070509@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61616 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2IJOiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:38:09 -0400
Received: by eekc1 with SMTP id c1so1203825eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 07:38:08 -0700 (PDT)
In-Reply-To: <504DFA97.7070509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/09/2012 16:35, Vlad Yasevich a =E9crit :
> On 09/10/2012 09:22 AM, Nicolas Dichtel wrote:
>> The goal of these patches is to fix the following problem: a session=
 is
>> established (TCP, SCTP) and after a new policy is inserted. The curr=
ent
>> code does not recalculate the route, thus the traffic is not encrypt=
ed.
>>
>> The patch propose to check flow_cache_genid value when checking a ds=
t
>> entry, which is incremented each time a policy is inserted or delete=
d.
>>
>> v2: use net->ipv4.rt_genid instead of flow_cache_genid (and thus sav=
e a test
>>      in fast path). Also move it to net->rt_genid, to be able to use=
 it for IPv6
>>      too. Note that IPv6 will have one more test in fast path.
>>
>> Patches are tested with TCP and SCTP, IPv4 and IPv6.
>>
>> Comments are welcome.
>>
>> Regards,
>> Nicolas
>>
>
> I am not sure this is right...  This has a side-effect that when an
> rt_cache_flush() is called, it invalidates IPv6 routes a well....
>
> Its all fine and good do this when a new policy is added, but not whe=
n IPv4
> routing table changes.
I already ask for this side effect, Eric answers me:
http://marc.info/?l=3Dlinux-netdev&m=3D134728265000776&w=3D2
