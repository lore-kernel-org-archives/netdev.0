From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 18:41:56 -0700
Message-ID: <m1pry4pe6z.fsf@ebiederm.dsl.xmission.com>
References: <fa.zy7JwM3jsOSgOCtqK2+rvFfdGjQ@ifi.uio.no>
	<fa.Zx9jkdx74KRPk1qghLrg9BCvfFU@ifi.uio.no>
	<fa.1TKmo5fKBZfHOQYq1bH4uMxOQek@ifi.uio.no>
	<fa.fjJG0rd93RGzZ4PSv/glscvAI0A@ifi.uio.no>
	<fa.7XLWa+gAWL3Q6I3O+hiS4UfcWpM@ifi.uio.no>
	<fa.QqYdKsBUWKSLLGXmxJCAtZxLYnE@ifi.uio.no> <47438820.5010300@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@redhat.com>,
	Roland McGrath <roland@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	Ingo Molnar <mingo@elte.hu>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Robert Hancock <hancockr@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51756 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbXKUBnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:43:53 -0500
In-Reply-To: <47438820.5010300@shaw.ca> (Robert Hancock's message of "Tue, 20
	Nov 2007 19:21:36 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Hancock <hancockr@shaw.ca> writes:

> Eric W. Biederman wrote:
>> Could you elaborate a bit on how the semantics of returning the
>> wrong information are more useful?
>>
>> In particular if a thread does the logical equivalent of:
>> grep Pid: /proc/self/status.  It always get the tgid despite
>> having a different process id.
>
> The POSIX-defined userspace concept of a PID requires that all threads appear to
> have the same PID. This is something that Linux didn't comply with under the old
> LinuxThreads implementation and was finally fixed with NPTL. This isn't a
> POSIX-defined interface, but I assume it's trying to be consistent with
> getpid(), etc.


Linux exports two fields in /proc/self/status:
Tgid:   32698
Pid:    32698

The tgid maps to the posix concept.  The pid is this context is the
thread id.

So it seems broken to me to return the same thread id for different threads.

Eric
