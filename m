From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 3/9] snet: introduce security/snet, Makefile and Kconfig changes
Date: Wed, 06 Jan 2010 07:04:07 +0100
Message-ID: <m2bph7ojl4.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-4-git-send-email-sam@synack.fr>
	<20100104183943.GB6034@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, sam@synack.fr
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:52890 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab0AFGEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 01:04:11 -0500
In-Reply-To: <20100104183943.GB6034@us.ibm.com> (Serge E. Hallyn's message of
	"Mon, 4 Jan 2010 12:39:43 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

>> diff --git a/security/snet/Kconfig b/security/snet/Kconfig
>> new file mode 100644
>> index 0000000..e1516a1
>> --- /dev/null
>> +++ b/security/snet/Kconfig
>> @@ -0,0 +1,22 @@
>> +#
>> +# snet
>> +#
>> +
>> +config SECURITY_SNET
>> +	bool "snet - Security for NETwork syscalls"
>> +	depends on SECURITY_NETWORK && IPV6
>
> Why depend on IPV6?

right, no need.

>
>> +	default n
>> +	---help---
>> +	Provide a generic netlink that reports networking's syscalls
>> +	to userspace
>
> And also wait for userspace to decide whether to authorize the
> syscall, right?  'report on' is very different.

I'm proposing this patch, which applies on top of previous

diff --git a/security/snet/Kconfig b/security/snet/Kconfig
index e1516a1..8ac7778 100644
--- a/security/snet/Kconfig
+++ b/security/snet/Kconfig
@@ -4,11 +4,11 @@
 
 config SECURITY_SNET
 	bool "snet - Security for NETwork syscalls"
-	depends on SECURITY_NETWORK && IPV6
+	depends on SECURITY_NETWORK
 	default n
 	---help---
-	Provide a generic netlink that reports networking's syscalls
-	to userspace
+	If this option is enabled, the kernel will include support for reporting
+	networking's syscalls to userspace and wait for a verdict
 
 config SECURITY_SNET_DEBUG
        bool "snet debug messages"

