From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: integer overflow in ip_idents_reserve
Date: Wed, 17 Dec 2014 06:11:40 -0800
Message-ID: <1418825500.9773.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5490A1F8.6020207@oracle.com>
	 <1418766460.9773.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1418771356.3449499.203748285.4B1A82B8@webmail.messagingengine.com>
	 <5490D920.5000104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrey Ryabinin <a.ryabinin@samsung.com>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5490D920.5000104@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-12-16 at 20:15 -0500, Sasha Levin wrote:

> I reported this one because there's usually some code to handle overflow
> in code that expects that and here there was none (I could see).

IP ID are best effort.

When sending one million IPv4 frames per second to a particular
destination, the 16bit ID space is recycled so fast that really their
precise values do not matter anymore.
You pray that IP fragments wont be needed at all.

(One of the idea I had was to detect this kind of stress and fallback to
a random generation, reducing false sharing, but this seemed a micro
optimization targeting synthetic benchmarks )

Thanks
