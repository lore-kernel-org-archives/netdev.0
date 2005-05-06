From: Asim Shankar <asimshankar@gmail.com>
Subject: SFQ: Reordering?
Date: Fri, 6 May 2005 16:53:51 -0500
Message-ID: <7bca1cb5050506145344d16b1e@mail.gmail.com>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I was looking through sch_sfq.c. From what I could make out, if the
perturbation period is non-zero (say Xseconds), then ever X seconds,
sfq_perturbation() is invoked. This changes the perturbation value
that will be used by the hash function, however, packets already
existing in the queue aren't rehashed.

As a result, new packets being enqueued will have a different hash
value and thus packet re-ordering will take place. I ran a quick test
using netperf and tcpdump and seem to notice this re-ordering.

Should complete rehashing take place in sfq_perturbation(), or am I
missing something? (I was looking at 2.6.9 and also took a cursory
glance at 2.6.11 on lxr.linux.no)

Thanks,

-- Asim
