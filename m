From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Sat, 18 Apr 2015 00:35:06 +0900
Message-ID: <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo wrote:
> * Implement netconsole retransmission support.  Matching rx socket on
>   the source port is automatically created for extended targets and
>   the log receiver can request retransmission by sending reponse
>   packets.  This is completely decoupled from the main write path and
>   doesn't make netconsole less robust when things start go south.

If the sender side can wait for retransmission, why can't we use
userspace programs (e.g. rsyslogd)?

For me, netconsole is mainly for saving kernel messages which cannot be
waited for a few deciseconds (e.g. system reset by softdog's timeout) and
for saving kernel messages (e.g. SysRq-t) during disk I/O hang up.
I have a logger for receiving netconsole messages at
http://sourceforge.jp/projects/akari/scm/svn/tree/head/branches/udplogger/
and things I expect for netconsole are shown below.

  (a) spool the message to send up to "1 line" or "adimn configured size"
      so that total number of small UDP packets can be reduced

  (b) don't hesitate to send the spooled message immediately if either
      kernel panic or system reset is in progress

  (c) allow different console log level for different console drivers
      so that I can send kernel messages via netconsole without making
      local console noisy
