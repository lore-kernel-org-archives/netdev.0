From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [RFC] Wireless extensions rethink
Date: Fri, 11 Jun 2004 11:49:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Gertjan van Wingerde" <gwingerde@home.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I was thinking along the same lines, however I was taking the 
> ethtool interface as the starting point (using a single ioctl 
> for all wireless operations). The private handlers would just 
> have to be converted to plain ioctls handled by the driver itself.
> 
> The attached patch can be used as a starting point for this.
> It is not complete (not by far), but it shows the basic structure.
> I've called the structure wlantool_ops, again using the 
> example set by ethtool.
> 
> Comments?

What if we just use the ethtool ioctl that's already defined, and extend
ethtool with a wireless option:

ethtool -w DEVNAME \
	[ nwid N|off|on} ] \
	[ freq x.xx ] \
	[ mode ad-hoc|managed|master|repeater|... ] \
	[ sens N ] \
	[ ... ]

Each one of the sub-options to -w would have it's own ETHTOOL_[G|S]W...
command as well as a type-safe ethtool_op.

Running ethtool DEVNAME dumps ETHTOOL_GW... :

Wireless settings for eth0:
        nwid: AB34
        freq: 2.422G
        mode: managed
        sens: -80

Good/bad idea?

-scott        
