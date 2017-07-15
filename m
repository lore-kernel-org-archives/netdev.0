From: xiang fei <liuxiang1999@gmail.com>
Subject: Re: [PATCH v2] net: davicom: dm9000: Avoid spinlock recursion during
 dm9000_timeout routine
Date: Sat, 15 Jul 2017 16:56:40 +0800
Message-ID: <CAPPcxxRnbE8Ldbm=JQxf=0xLf4VmFBDKrf+UqUUy2KS=qigbZg@mail.gmail.com>
References: <1496758626-2726-1-git-send-email-liu.xiang6@zte.com.cn> <20170607.143844.682492319776197931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: liu.xiang6@zte.com.cn, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607.143844.682492319776197931.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  In this patch, I don't change the routine of dm9000_phy_write().
  I just abstract the real phy operation from dm9000_phy_write()
  to make a new function dm9000_phy_write_reg(),
  which contains no lock.

  It is called in dm9000_phy_write() or dm9000_init_dm9000().
  Since dm9000_timeout() holds the main spinlock through the
  entire routine, dm9000_phy_write_reg() called in this routine is
  protected from another thread. I think there is no need to
  acquire any locks.

  The only problem is dm9000_init_dm9000() may be called
  in dm9000_open(). If another thread calls dm9000_open()
  in timeout may cause race condition.

  dm9000_init_dm9000() needs lock to avoid race condition,
  did you mean that?
  Thanks!
