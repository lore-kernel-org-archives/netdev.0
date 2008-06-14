From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 14 Jun 2008 05:49:04 -0400
Message-ID: <48539410.30804@garzik.org>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080614065616.GA32585@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Oplocks and leases are essentially lock on given file, which allows one
> client to operate on it. POHMELFS does not have locks now, and they will
> be created depending on how distributed server will require them. In the
> simplesst case it can just lock file for writing and do not allow its
> updates from other clients. Lock aciquite can be done at write_begin
> time. Without lock and writeback cache in your case writeback for file Y
> can happen before writeback for file X, but if client does not only
> write, but also sync after its write, then yes, client will see later
> updates after more earlier. POHMELFS does not broadcast its interest in
> the file content until real writing happens, i.e. at writeback time.
> Although I can add a mode, when the same will be done during
> write_begin() time. In that case your example will work without sync.


For /locking/, life is easy, you don't have to worry about disallowing 
client updates, because locking is advisory.  However, there are some 
guarantees you need for locking WRT write commit, and of course leases 
are a totally different animal where you do block client updates.

	Jeff


