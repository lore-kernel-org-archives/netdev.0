From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: switchdev: restrict vid range abstraction
Date: Wed, 29 Jul 2015 00:31:44 -0700
Message-ID: <CAE4R7bA5jh3Rgn_U1Sit3qW+i2vKNE++c9TYTJ8sp5j8h=awbw@mail.gmail.com>
References: <1437954348-11859-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437954348-11859-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 26, 2015 at 4:45 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> This patch replaces the vid_begin and vid_end members of the
> switchdev_obj_vlan structure for a single vid member. This way, the VID
> range abstraction is restricted to switchdev, not exposed to drivers.
>
> The main benefice to do so is to allow the prepare phase to be called
> for each VID, not only once for the whole range.
>
> For example, when adding VLANs 2-5, a switch chip may not be able to add
> hardware VLAN 2 due to some bridge restriction (thus must return
> -EOPNOTSUPP), while VLAN 3-5 are allowed.

Hi Vivien,

Since the netlink request (for example vlan add) includes the range,
I'm not seeing how we can response with success for the satisfied
vlans in the range, and also respond with an error for the unsatisfied
vlans in the range.   In other words, from the netlink msgs
perspective, we need to treat a vlan range as all-or-nothing.  So in
your example, if hw can't add vlan 2, we fail the entire request to
add range 2-5.  This is where the prepare phase checks to make sure
the entire request can be satisfied before committing to hw.

-scott
