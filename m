From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
Date: Wed, 9 Nov 2011 07:15:32 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1111090710000.1899@hadrien>
References: <1320586010-21931-1-git-send-email-julia@diku.dk> <1320586010-21931-3-git-send-email-julia@diku.dk> <20111108193817.GA3453@p183.telecom.by> <alpine.DEB.2.02.1111082113380.1880@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	kernel-janitors@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1111082113380.1880@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In looking through some examples, I see, e.g.:

 	if (strict_strtoul(buf, 10, &val) < 0)
  		return -EINVAL;
 	if (val < 1 || val > 2)
  		return -EINVAL;

In this case the only valid values are 1 and 2, which are much smaller 
than the u8 range.  Is it useful to use kstrtou8 anyway?  I see that 
kstrtou8 returns -ERANGE not -EINVAL when the value is out of bounds.  If 
kstrtou8 is to be used, should the subsequent if (val < 1 || val > 2) now 
return -ERANGE to be consistent?

julia
