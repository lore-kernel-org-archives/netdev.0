From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 22:17:31 +0200
Message-ID: <17056.47835.583602.151291@robur.slu.se>
References: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, <jdmason@us.ibm.com>,
        <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450BFE8@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ronciak, John writes:

 > With the same system (fairly high end with nothing major running on it)
 > we got rid of the dropped frames by just reducing the weight for 64.  So
 > the weight did have something to do with the dropped frames.  Maybe
 > other factors as well, but in static tests like this it sure looks like
 > the 64 value is wrong is some cases.

 It is possible that a lower weight forced your driver to disable interrupts
 and do packet reception w/o interrupts often this is more efficient as
 we get rid intr. latency etc.

 Again I think weight should only used for fairness and not control the
 threshold when to disable interrupts.
 
 You can test with a new policy in e1000_clean so you schedule for a new 
 poll if work_done (any pkts received) or tx_cleaned is true.

 Cheers.
						--ro
