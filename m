From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 15:49:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D0A446.8010607@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>	 <40CF263E.70009@home.nl>	 <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>	 <40D08769.3070106@home.nl> <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gertjan van Wingerde <gwingerde@home.nl>, netdev@oss.sgi.com,
        jkmaline@cc.hut.fi, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1087412780.3351.34.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I apologize for not responding earlier...

ethtool is the wrong direction for a few reasons,
* I really should have done ethtool via netlink
* We want to move away from pretending that 802.3 == 802.11, and using 
ethtool only serves to reinforce an association we don't want to make. 
"everything is ethernet" isn't really true :)


About overall API design...

When designing interfaces that the low-level drivers must implement, 
keep two things in mind:

* locking, security checks, and ioctl marshalling/thunking should be 
done in common kernel code, not each hardware driver.
* given that, each wireless hook (callback) should be purpose-specific 
-- which means each callback's arguments and return value vary, 
depending on the callback's purpose.  iw_handler must be killed, because 
that forces more code than necessary to be in each low-level driver.

The example to look at here is struct ethtool_ops, and net/core/ethtool.c.


Low-level drivers should be implementing small, fine-grained hooks NOT 
raw ioctl handlers.  In addition to fostering smaller hardware drivers, 
this insulates the driver interface from ABI changes to a certain degree.

	Jeff
