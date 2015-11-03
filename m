From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 3 Nov 2015 22:21:50 +0100
Message-ID: <5639256E.7010804@cumulusnetworks.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
 <1446583017-19021-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446583017-19021-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2015 09:36 PM, Jarod Wilson wrote:
> With moving netdev_sync_lower_features() after the .ndo_set_features
> calls, I neglected to verify that devices added *after* a flag had been
> disabled on an upper device were properly added with that flag disabled as
> well. This currently happens, because we exit __netdev_update_features()
> when we see dev->features == features for the upper dev. We can retain the
> optimization of leaving without calling .ndo_set_features with a bit of
> tweaking and a goto here.
> 
> Changing err to ret was somewhat arbitrary and makes the patch look more
> involved, but seems to better fit the altered use.
> 
> Fixes: fd867d51f ("net/core: generic support for disabling netdev features down stack")
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Nikolay Aleksandrov <razor@blackwall.org>
> CC: Michal Kubecek <mkubecek@suse.cz>
> CC: Alexander Duyck <alexander.duyck@gmail.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  net/core/dev.c | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 

Thanks for the quick response,

Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Tested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
