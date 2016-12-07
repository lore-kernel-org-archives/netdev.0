From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Wed, 7 Dec 2016 22:43:10 +0100
Message-ID: <cc10a750-b8ef-a600-4cd5-5b51904c5253@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161207213757.GC2250@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207213757.GC2250@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

On 07.12.2016 22:37, Pavel Machek wrote:
> On Wed 2016-12-07 21:05:38, Lino Sanfilippo wrote:
>> The driver uses a private lock for synchronization between the xmit
>> function and the xmit completion handler, but since the NETIF_F_LLTX flag
>> is not set, the xmit function is also called with the xmit_lock held.
>> 
>> On the other hand the xmit completion handler first takes the private lock
>> and (in case that the tx queue has been stopped) the xmit_lock, leading to
>> a reverse locking order and the potential danger of a deadlock.
>> 
>> Fix this by removing the private lock completely and synchronizing the xmit
>> function and completion handler solely by means of the xmit_lock. By doing
>> this remove also the now unnecessary double check for a stopped tx queue.
>> 
> 
> FYI, here's modified version. I believe _bh versions are needed, and
> I'm testing that version now. (Oh and I also ported it to net-next).
> 
> It survived 30 minutes of testing so far...
> 

First off, thanks for testing.
Hmm. I dont understand why _bh would be needed. We call that function from
BH context only (napi poll and timer).
Any idea?

Lino
