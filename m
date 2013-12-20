From: Florian Westphal <fw@strlen.de>
Subject: possible rose recvmsg behavior change after msg_namelen fixes
Date: Fri, 20 Dec 2013 17:02:07 +0100
Message-ID: <20131220160207.GC29632@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, linux-hams@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

recvmsg handler in net/rose/af_rose.c performs size-check
on  ->msg_namelen:

if (msg->msg_namelen >= sizeof(struct full_sockaddr_rose)) {
 /* something */
} else {
  /* else */
}

Now that msg_namelen is zeroed before the handler calls we always
hit the 'else' branch.

TBH i don't comprehend how this was/is supposed to work.

Could someone who is familiar with AF_ROSE look at this, before
I send untested patch that blindly chops off code?

Thanks!
