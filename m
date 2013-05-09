From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net] macvlan: fix passthru mode race between dev removal
 and rx path
Date: Thu, 09 May 2013 13:35:33 -0700
Message-ID: <1368131733.13473.103.camel@edumazet-glaptop>
References: <1368109420-14199-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com,
	kaber@trash.net, linux-kernel@vger.kernel.org, mtesar@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368109420-14199-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-09 at 16:23 +0200, Jiri Pirko wrote:
> Currently, if macvlan in passthru mode is created and data are rxed and
> you remove this device, following panic happens:
> 
> NULL pointer dereference at 0000000000000198
> IP: [<ffffffffa0196058>] macvlan_handle_frame+0x153/0x1f7 [macvlan]
> 
...
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
