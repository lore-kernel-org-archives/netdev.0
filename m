From: "David S. Miller" <davem@redhat.com>
Subject: Re: fix TCP roundtrip time update code
Date: Wed, 04 Jun 2003 00:51:45 -0700 (PDT)
Sender: linux-ia64-admin@linuxia64.org
Message-ID: <20030604.005145.98890243.davem@redhat.com>
References: <16093.34022.445246.52398@napali.hpl.hp.com>
	<3EDD8BD2.9040008@us.ibm.com>
	<16093.36723.418623.698303@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au,
        gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org,
        linux-ia64@linuxia64.org, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <linux-ia64-admin@linuxia64.org>
To: davidm@hpl.hp.com, davidm@napali.hpl.hp.com
In-Reply-To: <16093.36723.418623.698303@napali.hpl.hp.com>
Errors-To: linux-ia64-admin@linuxia64.org
List-Help: <mailto:linux-ia64-request@linuxia64.org?subject=help>
List-Post: <mailto:linux-ia64@linuxia64.org>
List-Subscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=subscribe>
List-Unsubscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=unsubscribe>
List-Archive: <http://lists.linuxia64.org/archives//linux-ia64/>
List-Id: netdev.vger.kernel.org

   From: David Mosberger <davidm@napali.hpl.hp.com>
   Date: Tue, 3 Jun 2003 23:19:31 -0700
   
   Yes, the "connection hangs/disappearances" where triggered by
   TCPAbortOnTimeout;

This is correct.

And it is the reason the connection dies silently.  Because
such write timeouts invoke tcp_done() which closes the connection
off silently.  This is correct behavior (sans the RTT bug David fixed
of course :)) because a host which hasn't responded at all from
so many repeated retransmission attempts isn't likely to get any
reset we send either :)
