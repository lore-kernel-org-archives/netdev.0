From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10327] New: keyboard stops responding after
 "ifdown eth0"
Date: Tue, 25 Mar 2008 17:16:08 -0700
Message-ID: <20080325171608.509f4ca7.akpm@linux-foundation.org>
References: <bug-10327-10286@http.bugzilla.kernel.org/>
	<20080325143941.300d415f.akpm@linux-foundation.org>
	<47E9721C.2000306@better.se>
	<47E99258.3060005@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcus Better <marcus@better.se>, bugme-daemon@bugzilla.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <47E99258.3060005@s5r6.in-berlin.de>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Mar 2008 01:01:28 +0100 Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> One possible reason for unresponsive keyboard is a workqueue job in the 
> shared workqueue sleeping very long or indefinitely.
> 
> Sky2.c has only one workqueue job: sky2_restart().

Yeah.

Marcus, please try something like this:

- become root

- run

	( sleep 10 ; echo t > /proc/sysrq-trigger ) &
	ifdown eth0

- wait a minute or so

- reboot

- See if the sysrq-t output made it to /var/log/messages

  If it did, please send it as reply-to-all to this email.  Try to avoid
  wordwrapping it, as many do.

Thanks.
