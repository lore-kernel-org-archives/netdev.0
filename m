From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless: recap of current issues (compatibility)
Date: Fri, 13 Jan 2006 17:20:54 -0500
Message-ID: <20060113222054.GK16166@tuxdriver.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213126.GF16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423019AbWAMWVH@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060113213126.GF16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compatibility
=============

The netlink configuration mechanism needs compatibility code to
translate wireless extension ioctls into netlink transactions.

We need to be an 802.11 stack (i.e. drivers need to handle 802.11
frames).  Ethernet emulation is bound to paint us into a corner
eventually (if it hasn't already).

We need an ethernet<->802.11 translational bridging interface for
compatibility, and to enable 802.1 bridging with ethernet.  This could
be a configuration setting for a wlan interface.  It might be limited
to wlan interfaces in station (or WDS) mode?

802.11 framing may break older protocols (e.g. DECnet).  I don't
see this as a big problem, as I imagine such installations aren't
rolling-out lots of WiFi...if I'm wrong, will the translational
bridging code resolve this issue?

Should a default wlan device be created at WiPHY init?  Should it
enable translational bridging?  I'm inclined against this, but is it
worthwhile for compatibility?  Could/should this be a configuration
option for the stack?

How about if WiPHY initialization triggered a netlink broadcast?
Then a daemon could monitor those broadcasts and create whatever wlan
devices (ethernet emulation, rfmon, none at all) that the daemon was
configured to create.  How would this effect modprobe behaviour?
-- 
John W. Linville
linville@tuxdriver.com
