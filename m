From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 11:01:44 -0700
Message-ID: <6d1249a6-6176-414e-0df8-d7df8dac1cbd@schaufler-ca.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <7d833f59-c68f-f779-4de4-15bc0b26ac7c@cumulusnetworks.com>
 <66709b13-15a7-8d03-9e84-e4be9aab60b5@schaufler-ca.com>
 <9998a0da-b273-43d4-84ad-a0539e6a69ac@cumulusnetworks.com>
 <5de95a23-fd64-d911-d4b0-88de51ab12a4@schaufler-ca.com>
 <9cb32128-176b-85cf-8ea8-465704f667e7@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux-Netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm31-vm6.bullet.mail.bf1.yahoo.com ([72.30.239.14]:57475 "EHLO
	nm31-vm6.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754168AbcGFSIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:08:48 -0400
In-Reply-To: <9cb32128-176b-85cf-8ea8-465704f667e7@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2016 10:40 AM, David Ahern wrote:
> On 7/6/16 10:24 AM, Casey Schaufler wrote:
>> On 7/6/2016 9:28 AM, David Ahern wrote:
>>> On 7/5/16 6:31 PM, Casey Schaufler wrote:
>>>> On 7/5/2016 5:49 PM, David Ahern wrote:
>>>>> On 7/5/16 5:38 PM, Casey Schaufler wrote:
>>>>>> I have encountered a system hang with my Smack
>>>>>> networking tests that bisects to the change below.
>>>>>> I can't say that I have any idea why the change
>>>>>> would impact the Smack processing, but there appears
>>>>>> to be some serious packet processing going on. The
>>>>>> Smack code is using CIPSO on the loopback interface.
>>>>>> The test is supposed to verify that labels can be
>>>>>> set on the packets using CIPSO. Unlabeled packets
>>>>>> do not appear to be impacted. I do not know if SELinux
>>>>>> is affected, and if not, why not. Smack and SELinux
>>>>>> use CIPSO differently.
>>>>>
>>>>> What are the commands to repeat the test?
>>>>>
>>>> There is a tar file attached with the tests.
>>>> Put the etc/smack/user file into /etc/smack/user.
>>>> In the tools-2012 directory run make to build
>>>> the tools. The test in question is called
>>>> testnetworking.sh and needs to be run as root.
>>>> You will need to configure Smack in the kernel,
>>>> of course.
>>>>
>>>
>>> I understand Paul's point and glad to see the changes are not causing issues with his SELinux testing.
>>>
>>> I have tried to reproduce the lockup you are seeing but not successful. I am using a jessie based VM with latest net-next kernel.
>>>
>>> root@kenny-jessie3:~/smack/tools-2012# zcat /proc/config.gz | grep SMACK
>>> CONFIG_SECURITY_SMACK=y
>>> CONFIG_SECURITY_SMACK_BRINGUP=y
>>> CONFIG_SECURITY_SMACK_NETFILTER=y
>>> # CONFIG_DEFAULT_SECURITY_SMACK is not set
>>
>> CONFIG_DEFAULT_SECURITY_SMACK needs to be set.
>
> ok. That caused more interesting output but still no hang after all of the snap-crackle-and-pops.
>
I find the test occasionally passes without hanging, but will
hang the system if repeated. I am running on Ubuntu and Fedora,
both with systemd, which may be a contributing factor. I run
under qemu, and am based on Linus' tree.
