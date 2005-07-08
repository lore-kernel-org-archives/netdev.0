From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Thu, 07 Jul 2005 20:00:34 -0700 (PDT)
Message-ID: <20050707.200034.74747399.davem@davemloft.net>
References: <Pine.LNX.4.61.0507071552130.24321@resonance.WorkGroup>
	<200507080106.j6816NKP022996@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        netdev@vger.kernel.org, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@neterion.com
In-Reply-To: <200507080106.j6816NKP022996@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Raghavendra Koushik" <raghavendra.koushik@neterion.com>
Date: Thu, 7 Jul 2005 18:06:19 -0700

> wmb() is to ensure ordered PIO writes.

wmb() does no such thing.  It only has influence on
load and store instructions done by the local processor,
it has no effect on what the PCI bus may do with PIO
writes (ie. post them).

If you need a PIO to complete in a specific order, you
have to read it back.  If you need PIO operations to occur
in a specific order wrt. cpu memory operations, mmiowb()
is what you need to use.
