From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: switchdev: restrict vid range abstraction
Date: Wed, 29 Jul 2015 11:28:42 -0700 (PDT)
Message-ID: <20150729.112842.1871916445536378243.davem@davemloft.net>
References: <1437954348-11859-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<CAE4R7bA5jh3Rgn_U1Sit3qW+i2vKNE++c9TYTJ8sp5j8h=awbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	jiri@resnulli.us, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAE4R7bA5jh3Rgn_U1Sit3qW+i2vKNE++c9TYTJ8sp5j8h=awbw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 29 Jul 2015 00:31:44 -0700

> Since the netlink request (for example vlan add) includes the range,
> I'm not seeing how we can response with success for the satisfied
> vlans in the range, and also respond with an error for the unsatisfied
> vlans in the range.   In other words, from the netlink msgs
> perspective, we need to treat a vlan range as all-or-nothing.  So in
> your example, if hw can't add vlan 2, we fail the entire request to
> add range 2-5.  This is where the prepare phase checks to make sure
> the entire request can be satisfied before committing to hw.

This was my concern with the change as well.

The user asked for the range to be installed, so if any portion
of it cannot be done we must not make any changes to the HW
configuration and fail the entire request.
