From: feyd <feyd@seznam.cz>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 10:35:38 +0100
Message-ID: <43CA176A.7080903@seznam.cz>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751868AbWAOIgP@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20060113221935.GJ16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Configuration seems to be coalescing around netlink.  Among other
> things, this technology provides for muliticast requests and
> asynchronous event notification.

On the other hand, the tree structure of sysfs can handle the
resource exclusivity and sharing naturaly.

A proposal of the layout:

template - template of device that can be created
profile  - exclusive set of templates and other resources

plain SoftMAC card:
/sys/class/ieee80211/phy0/profile0/template0/mode      # ap
                      |      |              /...       # ap specific stuff
                      |      |
                      |      *--->/template1/mode      # sta
                      |      |              /...       # sta specific stuff
                      |      |
                      |      *--->/template2/mode      # rfmon
                      |                     /...       # rfmon specific stuff
                      |
                      *->/profile
                         /channel
                         /txpower
                         /...                   # other phy specific stuff


FullMAC card with mode constraints:
/sys/class/ieee80211/phy0/profile0/template0/mode      # sta
                      |                     /...       # sta specific stuff
                      |
                      *->/profile1/template0/mode      # rfmon
                      |                     /...       # rfmon specific stuff
                      |
                      *->/...                   # phy specific stuff


virtual interface:
/sys/class/ieee80211/sta0/parent      # ->../phy0
                         /...


card with two chips that share some phy resources:
/sys/class/ieee80211/phy0/txpower     # shared txpower
                         /...

/sys/class/ieee80211/phy1/parent      # ->../phy0
                         /channel     # independent
                         /...

/sys/class/ieee80211/phy2/parent      # ->../phy0
                         /channel     # independent
                         /...

Feyd
