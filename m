From: Hugo Santos <hugo@innerghost.net>
Subject: sch_dsmark bug
Date: Sun, 11 Apr 2004 13:43:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40793D5A.9060706@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

I tried to contact the person whose name is in the source file but with
no success. While developing some code that handles with kernel's TC
objects direcly (by netlink) i found a small problem with dsmark (maybe
other scheds have it too, but i haven't checked). This is in linux 2.6.4
(there is no change in this context in 2.6.5); in dsmark_init, if opt is
NULL, the module will crash and TC will get stuck. the module will have a
ref count of 1 so i can't unload it, and i can't change any other TC
stuff since the netlink socket gets stuck when dsmark crashes. So, a simple

if (!opt) return -EINVAL;

would prevent such problems.

If you prefer i may send a patch, but since it's only a one line patch i didn't
send one.

Best regards,
Hugo Santos
