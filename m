From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: Build failure when installing atm ambassador firmware
Date: Wed, 1 Aug 2012 07:22:47 -0400
Message-ID: <20120801072247.589c7162@thirdoffive.cmf.nrl.navy.mil>
References: <50188D89.3040404@shealevy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shea Levy <shea@shealevy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50188D89.3040404@shealevy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jul 2012 21:59:37 -0400
Shea Levy <shea@shealevy.com> wrote:

> Hello,
> 
> When building with 
> MODLIB=/nix/store/ghx6s9hnk9irim7c7f63zrxqiv6xjh3w-linux-3.5/lib/modules/3.5.0 
> and 
> ="/nix/store/ghx6s9hnk9irim7c7f63zrxqiv6xjh3w-linux-3.5/lib/firmware", 
> building Linux 3.5 with CONFIG_ATM_AMBASSADOR=m fails with:
> 
> "make[2]: *** No rule to make target 
> `"/nix/store/ghx6s9hnk9irim7c7f63zrxqiv6xjh3w-linux-3.5/lib/firmware"/./', 
> needed by 
> `"/nix/store/ghx6s9hnk9irim7c7f63zrxqiv6xjh3w-linux-3.5/lib/firmware"/atmsar11.fw'.  
> Stop."

i think it might be trying to tell you that the target directory
$INSTALL_FW_PATH doesn't exist and is a prerequisite to actually
perform the action.

it complains about atmsar11.fw first because it just happens to be the
first firmware that needs to be installed.

/scratch/chas/net-next relax.53% ls -ld /tmp/funk
ls: cannot access /tmp/funk: No such file or directory
/scratch/chas/net-next relax.54% make INSTALL_FW_PATH="/tmp/funk" firmware_install
make[1]: *** No rule to make target `/tmp/funk/./', needed by `/tmp/funk/atmsar11.fw'.  Stop.
make: *** [firmware_install] Error 2
/scratch/chas/net-next relax.55% mkdir /tmp/funk
/scratch/chas/net-next relax.56% make INSTALL_FW_PATH="/tmp/funk" firmware_install
  INSTALL /tmp/funk/atmsar11.fw
  MKDIR   /tmp/funk/e100/
  INSTALL /tmp/funk/e100/d101m_ucode.bin
  INSTALL /tmp/funk/e100/d101s_ucode.bin
  INSTALL /tmp/funk/e100/d102e_ucode.bin
...

i am somewhat concerned that it appears to have an extra set of "'s in
the path as well.  how are you passing in INSTALL_FW_PATH?  i can get
the same result with:

/scratch/chas/net-next relax.57% make 'INSTALL_FW_PATH="/tmp/funk"' firmware_install
make[1]: *** No rule to make target `"/tmp/funk"/./', needed by `"/tmp/funk"/atmsar11.fw'.  Stop.
make: *** [firmware_install] Error 2

but it would be wrong to do it this way.
