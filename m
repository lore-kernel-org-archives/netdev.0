From: Jesse Barnes <jesse.barnes@intel.com>
Subject: Re: [PATCH] use mmiowb in tg3_poll
Date: Tue, 31 May 2005 09:45:36 -0700
Message-ID: <200505310945.36903.jesse.barnes@intel.com>
References: <200410211628.06906.jbarnes@engr.sgi.com> <Pine.LNX.4.61.0505300925570.11645@linux.site> <1117544022.6134.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: Arthur Kepner <akepner@sgi.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com,
        gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1117544022.6134.54.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday, May 31, 2005 5:53 am, jamal wrote:
> Did i read correctly that your reads are about 2x more expensive than
> the writes?

The test above just measures the difference between using a full PIO 
read to ensure write ordering vs. the lighter weight mmiowb call.  As 
for your question though, non-relaxed reads are very expensive on the 
Altix platform due to its highly distributed NUMA I/O architecture.  
The _relaxed variants can be quite fast however, and can be used 
anytime a PIO read doesn't imply anything about previous DMA 
transactions.

Jesse
