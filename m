From: Paul Moore <paul@paul-moore.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 10:03:33 -0400
Message-ID: <CAHC9VhRCWgqR1k8vB8hwhiVUyu-hndpuvg9rZPfurVoof65wYg@mail.gmail.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com> <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	Linux-Netdev <netdev@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35168 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbcGFOEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 10:04:30 -0400
Received: by mail-oi0-f51.google.com with SMTP id r2so271782370oih.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 07:03:34 -0700 (PDT)
In-Reply-To: <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 8:50 AM, Paul Moore <paul@paul-moore.com> wrote:
> On Tue, Jul 5, 2016 at 8:38 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
>> I have encountered a system hang with my Smack
>> networking tests that bisects to the change below.
>> I can't say that I have any idea why the change
>> would impact the Smack processing, but there appears
>> to be some serious packet processing going on. The
>> Smack code is using CIPSO on the loopback interface.
>> The test is supposed to verify that labels can be
>> set on the packets using CIPSO. Unlabeled packets
>> do not appear to be impacted. I do not know if SELinux
>> is affected, and if not, why not. Smack and SELinux
>> use CIPSO differently.
>
> For the past several months I've been running the SELinux testsuite on
> a weekly basis against Linus' kernel plus the SELinux and audit
> development trees and I haven't noticed any problems that haven't
> already been reported.  While not exhaustive, the testsuite does
> exercise the NetLabel/CIPSO code.  I'll see if I can take a closer
> look at the Smack code, but do you rely on the inet_skb_param values
> in Smack?  We did have a similar problem in the NetLabel core code
> that we fixed with 04f81f0154e4bf002be6f4d85668ce1257efa4d9; it's
> possible there is a similar problem in code that we just aren't
> exercising with SELinux at the moment.
>
> * https://github.com/SELinuxProject/selinux-testsuite
> * https://copr.fedorainfracloud.org/coprs/pcmoore/kernel-secnext

I just ran some additional SELinux/NetLabel tests on 4.7-rc6
(+selinux#next +audit#next) and everything worked as expected.  This
is looking more and more like a Smack specific bug.  I took a quick
look at the NetLabel/CIPSO code as well as some of the Smack code and
nothing jumped out at me as obviously wrong, but it has been years
since I've looked at the Smack code in any detail.

I'm happy to help debug, but I think it might be more helpful if you
take a closer look at the Smack code first.

-- 
paul moore
www.paul-moore.com
