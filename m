From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e100-3.0.0_dev8 "Minneapolis Moline" release
Date: Wed, 18 Jun 2003 09:52:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D97A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jason Lunz" <lunz@reflexsecurity.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> It's running on my workstation with no problems. passes the 
> "ping -qf" load test.

Do you have any other tests you can through at it?

> ethtool output seems normal, but what's with the rx-mini and 
> rx-jumbo max settings in the -g output?

Good catch.  Needs this:

@@ -1848,8 +1848,12 @@ static int e100_ethtool(struct net_devic
        case ETHTOOL_GRINGPARAM:
                ecmd->ring.rx_max_pending = rfds->max;
                ecmd->ring.tx_max_pending = cbs->max;
+               ecmd->ring.rx_mini_max_pending = 0;
+               ecmd->ring.rx_jumbo_max_pending = 0;
                ecmd->ring.rx_pending = rfds->count;
                ecmd->ring.tx_pending = cbs->count;
+               ecmd->ring.rx_mini_pending = 0;
+               ecmd->ring.rx_jumbo_pending = 0;
                if(copy_to_user(useraddr, ecmd, sizeof(ecmd->ring)))
                        err = -EFAULT;
                break;

-scott
