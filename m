From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: synchronize_net()?
Date: Fri, 12 Sep 2003 20:46:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913034611.GA83212@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test5, synchronize_net() is simply:

/* Synchronize with packet receive processing. */
void synchronize_net(void) 
{
        might_sleep();
        synchronize_kernel();
}

The "might_sleep()" isn't needed -- synchronize_kernel() calls
wait_for_completion() which also calls it.  Is there any reason for
keeping synchronize_net() around as a seperate function?  Maybe
it should just be a #define instead.

-Mitch
