From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 13:28:01 -0700
Message-ID: <4BF1A6D1.70507@candelatech.com>
References: <4BF192F9.8000008@candelatech.com> <4BF1A352.5020500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47942 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab0EQU2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 16:28:04 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o4HKS1db001808
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 13:28:01 -0700
In-Reply-To: <4BF1A352.5020500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2010 01:13 PM, Ben Greear wrote:
> On 05/17/2010 12:03 PM, Ben Greear wrote:
>> On older releases, you can do this with iproute:
>>
>> # ip ru add from 9.9.9.2/32 table 226 pref 400
>> #
>>
>> But, in latest git, it returns an error:
>> # ip ru add from 9.9.9.2/32 table 226 pref 400
>> Error: an inet prefix is expected rather than "9.9.9.2/32".
>>
>> Is that on purpose?
>
> I was thinking maybe this was a library issue, since I compiled
> on one machine and ran the 'ip' exe on another. So, I tried compiling
> on the test system.

I'm not thinking too well today, but this patch fixes the compile.
No idea if it's actually correct code.
Still can't add the rule like I was trying...but at least it's probably
not an issue with libraries:

[root@ct503-10G-09 iproute2]# git diff
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 48f7b1e..4d4481a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -331,13 +331,13 @@ int print_linkinfo(const struct sockaddr_nl *who,
                                 );
                 }
         }
-       if (do_link && tb[IFLA_VFINFO] && tb[IFLA_NUM_VF]) {
+       if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
                 SPRINT_BUF(b1);
-               struct rtattr *rta = tb[IFLA_VFINFO];
+               struct rtattr *rta = tb[IFLA_VFINFO_LIST];
                 struct ifla_vf_info *ivi;
                 int i;
                 for (i = 0; i < *(int *)RTA_DATA(tb[IFLA_NUM_VF]); i++) {
-                       if (rta->rta_type != IFLA_VFINFO) {
+                       if (rta->rta_type != IFLA_VFINFO_LIST) {
                                 fprintf(stderr, "BUG: rta type is %d\n", rta->rta_type);
                                 break;
                         }


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

