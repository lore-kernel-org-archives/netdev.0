From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] fix file counting
Date: Sat, 18 Feb 2006 12:14:02 +0000
Message-ID: <20060218121402.GB911@infradead.org>
References: <20060217154147.GL29846@in.ibm.com> <20060217154337.GM29846@in.ibm.com> <20060217154626.GN29846@in.ibm.com> <20060218010414.1f8d6782.akpm@osdl.org> <20060218092517.GP29846@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	paulmck@us.ibm.com, dada1@cosmosbay.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751179AbWBRMOM@vger.kernel.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060218092517.GP29846@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > - Make the get_max_files export use _GPL - only unix.ko uses it.

The real question is, does af_unix really need to allow beeing built
modular?  It's quite different from other network protocol and deeply
tied to the kernel due to things like descriptor passing or using
the filesystem namespace.  I already had to export another symbol that
really should be internal just for it, and if one module acquires lots
of such hacks it's usually a bad sign..
