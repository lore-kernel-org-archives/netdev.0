From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 3 Jun 2003 11:45:24 -0700
Sender: linux-ia64-admin@linuxia64.org
Message-ID: <16092.60612.352739.581639@napali.hpl.hp.com>
References: <200306031552.h53FqknC023999@napali.hpl.hp.com>
	<1054662070.701.6.camel@tux.rsn.bth.se>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org,
	netdev@oss.sgi.com
Return-path: <linux-ia64-admin@linuxia64.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1054662070.701.6.camel@tux.rsn.bth.se>
Errors-To: linux-ia64-admin@linuxia64.org
List-Help: <mailto:linux-ia64-request@linuxia64.org?subject=help>
List-Post: <mailto:linux-ia64@linuxia64.org>
List-Subscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=subscribe>
List-Unsubscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=unsubscribe>
List-Archive: <http://lists.linuxia64.org/archives//linux-ia64/>
List-Id: netdev.vger.kernel.org

>>>>> On 03 Jun 2003 19:41:11 +0200, Martin Josefsson <gandalf@wlug.westbo.se> said:

  Martin> (trimmed CC line and added netdev) On Tue, 2003-06-03 at
  Martin> 17:52, David Mosberger wrote:
  >> One of those very-hard-to-track-down, trivial-to-fix kind of
  >> problems: without this patch, TCP roundtrip time measurements
  >> will corrupt the routing cache's RTT estimates under heavy
  >> network load (the bug causes RTAX_RTT to go negative, but since
  >> its type is u32, you end up with a huge positive value...).  From
  >> there on, later TCP connections quickly will go south.

  >> The typo was introduced 8 months ago in v1.29 of the file by the
  >> patch entitled "Cleanup DST metrics and abstrct MSS/PMTU
  >> further".

  Martin> I tested this patch and it looks like it has cured my
  Martin> mysterious TCP stalls.

Yes, this sounds reasonable.  I wasn't very clear on this point, but
"by going south" I meant that TCP is starting to misbehave.  In
particular, you'll likely end up with the kernel aborting ESTABLISHED
TCP connections with extreme prejudice (and in violation of the TCP
protocol), because it thought that it had been unable to communicate
with the remote end for a _very_ long time.  The net effect typically
is that you end up with one end having a connection that's in the
ESTABLISHED state and the other end having no trace of that
connection.

	--david
