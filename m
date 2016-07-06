From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 07:42:57 -0700
Message-ID: <33d3964b-b68e-33d5-ca55-bb810633ed7d@schaufler-ca.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com>
 <CAHC9VhRCWgqR1k8vB8hwhiVUyu-hndpuvg9rZPfurVoof65wYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	Linux-Netdev <netdev@vger.kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17-vm1.bullet.mail.bf1.yahoo.com ([98.139.213.55]:38784 "EHLO
	nm17-vm1.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753650AbcGFOnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 10:43:00 -0400
In-Reply-To: <CAHC9VhRCWgqR1k8vB8hwhiVUyu-hndpuvg9rZPfurVoof65wYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2016 7:03 AM, Paul Moore wrote:
> On Wed, Jul 6, 2016 at 8:50 AM, Paul Moore <paul@paul-moore.com> wrote:
>> On Tue, Jul 5, 2016 at 8:38 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
>>> I have encountered a system hang with my Smack
>>> networking tests that bisects to the change below.
>>> I can't say that I have any idea why the change
>>> would impact the Smack processing, but there appears
>>> to be some serious packet processing going on. The
>>> Smack code is using CIPSO on the loopback interface.
>>> The test is supposed to verify that labels can be
>>> set on the packets using CIPSO. Unlabeled packets
>>> do not appear to be impacted. I do not know if SELinux
>>> is affected, and if not, why not. Smack and SELinux
>>> use CIPSO differently.
>> For the past several months I've been running the SELinux testsuite on
>> a weekly basis against Linus' kernel plus the SELinux and audit
>> development trees and I haven't noticed any problems that haven't
>> already been reported.  While not exhaustive, the testsuite does
>> exercise the NetLabel/CIPSO code.  I'll see if I can take a closer
>> look at the Smack code, but do you rely on the inet_skb_param values
>> in Smack?  We did have a similar problem in the NetLabel core code
>> that we fixed with 04f81f0154e4bf002be6f4d85668ce1257efa4d9; it's
>> possible there is a similar problem in code that we just aren't
>> exercising with SELinux at the moment.
>>
>> * https://github.com/SELinuxProject/selinux-testsuite
>> * https://copr.fedorainfracloud.org/coprs/pcmoore/kernel-secnext
> I just ran some additional SELinux/NetLabel tests on 4.7-rc6
> (+selinux#next +audit#next) and everything worked as expected.  This
> is looking more and more like a Smack specific bug.

That would not surprise me at all. Smack uses CIPSO more
extensively than SELinux.

>   I took a quick
> look at the NetLabel/CIPSO code as well as some of the Smack code and
> nothing jumped out at me as obviously wrong, but it has been years
> since I've looked at the Smack code in any detail.
>
> I'm happy to help debug, but I think it might be more helpful if you
> take a closer look at the Smack code first.

That was where my long weekend was spent. Except for a trivial
change in the signal delivery code, there haven't been changes
in Smack recently.

That's why I took the bisect route to try to find the problem.

I am perfectly willing to accept that there's something that
I'm doing wrong (I often do things wrong). In this case, it's
got to be something that I've been getting away with for quite
some time.
