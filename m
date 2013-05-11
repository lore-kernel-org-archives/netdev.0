From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] macvlan: fix passthru mode race between dev
 removal and rx path
Date: Sat, 11 May 2013 16:25:54 -0700 (PDT)
Message-ID: <20130511.162554.1852680841693318294.davem@davemloft.net>
References: <1368109420-14199-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, kaber@trash.net,
	linux-kernel@vger.kernel.org, mtesar@redhat.com,
	eric.dumazet@gmail.com
To: jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368109420-14199-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 May 2013 16:23:40 +0200

> Currently, if macvlan in passthru mode is created and data are rxed and
> you remove this device, following panic happens:
> 
> NULL pointer dereference at 0000000000000198
> IP: [<ffffffffa0196058>] macvlan_handle_frame+0x153/0x1f7 [macvlan]
> 
> I'm using following script to trigger this:
 ...
> I run this script while "ping -f" is running on another machine to send
> packets to e1 rx.
> 
> Reason of the panic is that list_first_entry() is blindly called in
> macvlan_handle_frame() even if the list was empty. vlan is set to
> incorrect pointer which leads to the crash.
> 
> I'm fixing this by protecting port->vlans list by rcu and by preventing
> from getting incorrect pointer in case the list is empty.
> 
> Introduced by: commit eb06acdc85585f2 "macvlan: Introduce 'passthru' mode to takeover the underlying device"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks!
