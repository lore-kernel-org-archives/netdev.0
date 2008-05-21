From: Dave Jones <davej@codemonkey.org.uk>
Subject: Fwd: [Bug 447812] New: Netlink messages from "tc"  to sch_netem
	module are not interpreted correctly
Date: Wed, 21 May 2008 17:45:23 -0400
Message-ID: <20080521214523.GB22591@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from testure.choralone.org ([194.9.77.134]:59966 "EHLO
	testure.choralone.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760250AbYEUVoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 17:44:13 -0400
Received: from davej by testure.choralone.org with local (Exim 4.69)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Jyw7f-0006Qq-3X
	for netdev@vger.kernel.org; Wed, 21 May 2008 22:45:23 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


-- 
http://www.codemonkey.org.uk

--17pEHd4RhPHOinZp
Content-Type: message/rfc822
Content-Disposition: inline

Return-path: <apache@redhat.com>
X-Spam-Checker-Version: SpamAssassin 3.2.4 (2008-01-01) on
	testure.choralone.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=5.0 tests=AWL,BAYES_00,
	RCVD_IN_DNSWL_MED autolearn=ham version=3.2.4
Envelope-to: davej@codemonkey.org.uk
Delivery-date: Wed, 21 May 2008 22:42:26 +0100
Received: from mx1-phx.redhat.com ([209.132.177.92] helo=mx1.util.phx.redhat.com)
	by testure.choralone.org with esmtp (Exim 4.69)
	(envelope-from <apache@redhat.com>)
	id 1Jyw4n-0006GL-8k
	for davej@codemonkey.org.uk; Wed, 21 May 2008 22:42:26 +0100
Received: from bz-web2.app.phx.redhat.com (nat-pool.util.phx.redhat.com [10.8.5.200])
	by mx1.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id m4LLf7nF029840
	for <davej@codemonkey.org.uk>; Wed, 21 May 2008 17:41:08 -0400
Received: from bz-web2.app.phx.redhat.com (localhost.localdomain [127.0.0.1])
	by bz-web2.app.phx.redhat.com (8.13.1/8.13.1) with ESMTP id m4LLf2id006335
	for <davej@codemonkey.org.uk>; Wed, 21 May 2008 17:41:07 -0400
Received: (from apache@localhost)
	by bz-web2.app.phx.redhat.com (8.13.1/8.13.1/Submit) id m4LLcPxU005779;
	Wed, 21 May 2008 17:38:25 -0400
Date: Wed, 21 May 2008 17:38:25 -0400
From: bugzilla@redhat.com
To: davej@codemonkey.org.uk
Subject: [Bug 447812] New: Netlink messages from "tc"  to sch_netem module are not interpreted correctly
Content-type: text/plain; charset=utf-8
Message-ID: <bug-447812-263030@bugzilla.redhat.com>
X-Loop: bugzilla@redhat.com
X-BeenThere: bugzilla@redhat.com
X-Bugzilla-Product: Fedora
X-Bugzilla-Version: rawhide
X-Bugzilla-Component: kernel
X-Bugzilla-Status: NEW
X-Bugzilla-Comment: Public
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Changed-Fields: New

Please do not reply directly to this email. All additional
comments should be made in the comments box of this bug report.




https://bugzilla.redhat.com/show_bug.cgi?id=447812

           Summary: Netlink messages from "tc"  to sch_netem module are not
                    interpreted correctly
           Product: Fedora
           Version: rawhide
          Platform: x86_64
        OS/Version: Linux
            Status: NEW
          Severity: medium
          Priority: low
         Component: kernel
        AssignedTo: kernel-maint@redhat.com
        ReportedBy: karl@iwl.com
         QAContact: extras-qa@fedoraproject.org
                CC: nhorman@redhat.com


>From Bugzilla Helper:
User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.8.1.14) Gecko/20080416 Fedora/2.0.0.14-1.fc8 Firefox/2.0.0.14

Description of problem:
When using the tc command to send netem settings to the netem module, the messages cause a kernel error to be emitted into dmesg and part of the data in the netlink message may be lost.

This makes the netem mechanism quietly unreliable when used on a 2.6.25 kernel.

I have tried this on all of the 2.6.25.X kernels and the results are the same.

This problem did not occur with the2.6.24 kernels.

The problem is the same on x86_64 and i386 architectures.

Version-Release number of selected component (if applicable):
2.6.25.3-18.fc9.x86_64

How reproducible:
Always


Steps to Reproduce:
Here is a shell script (needs to be run as root):

#!/bin/bash

DEV=eth0
TC=/sbin/tc

# Clean out any prior settings.
# This may generate some messages of the form:
#   RTNETLINK answers: No such file or directory
${TC} qdisc del dev ${DEV} root > /dev/null 2>&1
${TC} qdisc del dev ${DEV} ingress > /dev/null 2>&1

${TC} qdisc add dev ${DEV} root handle 1: prio bands 5 priomap 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4
${TC} qdisc add dev ${DEV} parent 1:1 handle 10: netem

# If the kernel is acting up this will cause a kernel
# message of the following form to be emitted and visible
# via dmesg | tail
#  netlink: 12 bytes leftover after parsing attributes.
${TC} qdisc change dev ${DEV} parent 1:1 handle 10: netem delay 50ms 5ms 10% corrupt 8%
echo
echo
echo "Does the following contain a netlink message about leftover bytes?"
echo "If so, the the kernel code in .../net/netlink/attr.c"
echo "is unhappy with the netlink messages from the tc command."
dmesg | tail -3

# Take a look at the netem status and see whether a corruption
# value has been established or not.
echo
echo
echo "Does the following show a corruption setting or not?"
echo "If not then the kernel module .../net/sched/sch_netem.c"
echo "did not pick up all the pieces from the netlink message"
echo "complained of by .../net/netlink/attr.c"
echo "A GOOD response should look like this:"
echo "    qdisc prio 1: root bands 5 priomap  4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4"
echo "    qdisc netem 10: parent 1:1 limit 1000 delay 50.0ms  5.0ms 10% corrupt 8%"

${TC} qdisc show dev ${DEV}

${TC} qdisc show dev ${DEV} | grep netem | grep -q corrupt > /dev/null
RC=$?

if [ "${RC}" != 0 ] ; then
   echo
   echo "I did not see any corruption setting, did you?"
   echo "Seems like there is a bug in the tc-to-netem module netlink."
fi

# Clean up after ourselves.
# This may generate some messages of the form:
#   RTNETLINK answers: No such file or directory
${TC} qdisc del dev ${DEV} root > /dev/null 2>&1
${TC} qdisc del dev ${DEV} ingress > /dev/null 2>&1


Actual Results:
On all 2.6.25 kernels, whether i386 or x86_64, this causes a kernel message to be emitted about unused bytes.  In addition, the netem module does not pick up all of the data that was sent to it, such as the corruption settings.

All of this stuff worked in the 2.6.24 kernels.

Expected Results:
No kernel message should have been emitted.

The data sent by the user via the "tc" command should have been received by the netem module.

Additional info:
I tried to figure out whether the problem is in "tc" or in the kernel.

So I ran some old "tc" binaries on new kernels.  The result was the same as if I had run current "tc" binaries.  This suggests that the problem is in the kernel rather than in the "tc" command.

I also did some simple printk debugging on the way that .../net/netlink/attr.c was parsing the netlink messages.  The number of bytes that it reported unused always was the sizeof the first chunk of netem data that was lost in the netlink message.

-- 
Configure bugmail: https://bugzilla.redhat.com/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--17pEHd4RhPHOinZp--
