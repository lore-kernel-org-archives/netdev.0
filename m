From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: reject invalid MTU values
Date: Sun, 19 Feb 2012 18:54:20 -0500 (EST)
Message-ID: <20120219.185420.1710587455826987655.davem@davemloft.net>
References: <1329481995-28384-1-git-send-email-pbonzini@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pbonzini@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329481995-28384-1-git-send-email-pbonzini@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Bonzini <pbonzini@redhat.com>
Date: Fri, 17 Feb 2012 13:33:15 +0100

> The 8139cp driver has a change_mtu function that has not been
> enabled since the dawn of the git repository.  However, the
> generic eth_change_mtu is not used in its place, so that
> invalid MTU values can be set on the interface.
> 
> This patch salvages the broken code for the single case of
> setting the MTU while the interface is down, which is safe
> and also includes the range check.

Well, now you can't change the MTU while the device is up
which to me is a worse problem than MTU validation because
this breaks valid things that potentially worked previously.

Also you didn't bother to give your patch a proper signoff.

You're going to have to fix cp_change_mtu() so that it does the
correct HW reset sequence when the MTU changes, otherwise I am not
going to apply this patch.
