From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 19:21:36 -0600
Message-ID: <47438820.5010300@shaw.ca>
References: <fa.zy7JwM3jsOSgOCtqK2+rvFfdGjQ@ifi.uio.no>
 <fa.Zx9jkdx74KRPk1qghLrg9BCvfFU@ifi.uio.no>
 <fa.1TKmo5fKBZfHOQYq1bH4uMxOQek@ifi.uio.no>
 <fa.fjJG0rd93RGzZ4PSv/glscvAI0A@ifi.uio.no>
 <fa.7XLWa+gAWL3Q6I3O+hiS4UfcWpM@ifi.uio.no>
 <fa.QqYdKsBUWKSLLGXmxJCAtZxLYnE@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	Roland McGrath <roland@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	Ingo Molnar <mingo@elte.hu>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:6229 "EHLO
	pd4mo1so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932434AbXKUBVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:21:39 -0500
In-reply-to: <fa.QqYdKsBUWKSLLGXmxJCAtZxLYnE@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Could you elaborate a bit on how the semantics of returning the
> wrong information are more useful?
> 
> In particular if a thread does the logical equivalent of:
> grep Pid: /proc/self/status.  It always get the tgid despite
> having a different process id.

The POSIX-defined userspace concept of a PID requires that all threads 
appear to have the same PID. This is something that Linux didn't comply 
with under the old LinuxThreads implementation and was finally fixed 
with NPTL. This isn't a POSIX-defined interface, but I assume it's 
trying to be consistent with getpid(), etc.

> How can that possibly be useful or correct?
> 
> From the kernel side I really think the current semantics of /proc/self
> in the context of threads is a bug and confusing.  All of the kernel
> developers first reaction when this was pointed out was that this
> is a regression.
> 
> If it is truly useful to user space we can preserve this API design
> bug forever.  I just want to make certain we are not being bug
> compatible without a good reason.
> 
> Currently we have several kernel side bugs with threaded
> programs because /proc/self does not do the intuitive thing.  Unless
> something has changed recently selinux will cause accesses by a
> non-leader thread to fail when accessing files through /proc/self.
> 
> So far the more I look at the current /proc/self behavior the
> more I am convinced it is broken, and useless.  Please help me see
> where it is useful, so we can justify keeping it.

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

