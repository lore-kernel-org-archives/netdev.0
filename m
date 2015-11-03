From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 03 Nov 2015 16:58:36 -0500
Message-ID: <56392E0C.1030509@redhat.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com> <1446583017-19021-1-git-send-email-jarod@redhat.com> <20151103215310.GA7839@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151103215310.GA7839@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek wrote:
> On Tue, Nov 03, 2015 at 03:36:57PM -0500, Jarod Wilson wrote:
>> With moving netdev_sync_lower_features() after the .ndo_set_features
>> calls, I neglected to verify that devices added *after* a flag had been
>> disabled on an upper device were properly added with that flag disabled as
>> well. This currently happens, because we exit __netdev_update_features()
>> when we see dev->features == features for the upper dev. We can retain the
>> optimization of leaving without calling .ndo_set_features with a bit of
>> tweaking and a goto here.
>
> I haven't reviewed the patch yet (I'm going to take a look with fresher
> mind in the morning) but if you are going to handle this in a generic
> way, you may want to remove the LRO specific hacks added to
> bond_enslave() and team_port_add() by commit fbe168ba91f7 ("net: generic
> dev_disable_lro() stacked device handling").

Yeah, that's on tap for a follow-up series. I wanted to get all this in 
first and soaked before pulling those bits out. My current 
haven't-yet-fully-investigated thinking is that dev_disable_lro() can go 
away entirely, not just the hacks added to bond and team.

-- 
Jarod Wilson
jarod@redhat.com
