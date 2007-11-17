From: Andrew Morgan <morgan@kernel.org>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Sat, 17 Nov 2007 15:52:59 -0800
Message-ID: <473F7EDB.60701@kernel.org>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org> <20071115164441.67a8e2df.akpm@linux-foundation.org> <473E794A.4060107@kernel.org> <200711170848.35726.kjwinchester@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:47421 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540AbXKQXxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 18:53:07 -0500
In-Reply-To: <200711170848.35726.kjwinchester@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Kevin,

Can you try this quick hack?

diff --git a/kernel/capability.c b/kernel/capability.c
index e57d1aa..4088610 100644
- --- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -109,7 +109,7 @@ out:
                        kdata[i].permitted = pP.cap[i];
                        kdata[i].inheritable = pI.cap[i];
                }
- -               while (i < _LINUX_CAPABILITY_U32S) {
+               while (0 && (i < _LINUX_CAPABILITY_U32S)) {
                        if (pE.cap[i] || pP.cap[i] || pP.cap[i]) {
                                /* Cannot represent w/ legacy structure */
                                return -ERANGE;

Thanks

Andrew

Kevin Winchester wrote:
> On November 17, 2007 01:16:58 am Andrew Morgan wrote:
>> Hi,
>>
>> This warning is just saying that you might want to reconsider
>> recompiling your dhclient with a newer libcap - which has native support
>> for 64-bit capabilities. This is supposed to be informative, and not be
>> associated with any particular error.
>>
>> From your comments, you believe that this patch causes something in your
>> boot process to fail. Can you supply some detail about the version of
>> dhclient you are using? I'd like to understand exactly what it is doing
>> (via libcap).
>>
>> Thanks
>>
> 
> The boot succeeds (and appears to bring initialize the network adapter 
> properly - it autonegotiates a 100Mbps link speed), but the dhcp client is 
> never able to get an address.  However, applying the rc2-mm1 patch series up 
> to just before:
> 
>   add-64-bit-capability-support-to-the-kernel.patch
> 
> results in a working kernel.  Applying just this patch causes the failure.  To 
> be sure, I also tried applying the above patch plus the following ones:
> 
>   add-64-bit-capability-support-to-the-kernel-checkpatch-fixes.patch
>   add-64-bit-capability-support-to-the-kernel-fix.patch
>   add-64-bit-capability-support-to-the-kernel-fix-fix.patch
>   remove-unnecessary-include-from-include-linux-capabilityh.patch
> 
> but the problem still occurs even with all of these.
> 
> As to versions, I'm running Kubuntu gutsy, so I have the default:
> 
> dhcp3-client           3.0.5-3ubuntu4
> libcap1                1:1.10-14build1
> 
> packages installed.
> 
> Let me know if you need any other information, or if you have a patch you 
> would like tested.
> 
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFHP37LQheEq9QabfIRAst5AJ9Nsw0RtF2NDuUAMvQZh5OFWEB4ugCeIxMH
lp5/Ka7SJZLIrQpZDijrd1E=
=GN18
-----END PGP SIGNATURE-----
