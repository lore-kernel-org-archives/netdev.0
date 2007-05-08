From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: Getting make net/built-in.o Error with 2.6.21.1
	Build
Date: Tue, 8 May 2007 17:49:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705081740550.16923@twin.jikos.cz>
References: <463FB6B0.3070005@pcburn.com>
	<a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bluez-devel@lists.sourceforge.net, chris@pcburn.com,
	Marcel Holtmann <marcel@holtmann.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007, Satyam Sharma wrote:

> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > net/built-in.o: In function `hidp_add_connection':
> > (.text+0x8bb08): undefined reference to `hid_ff_init'
> > make: *** [.tmp_vmlinux1] Error 1
> You've got CONFIG_BT_HIDP=y there but CONFIG_USB_HID=m. The trivial 
> patch below solves it. To test, you can just "make oldconfig" on the 
> same .config that broke above and then proceed to make bzImage.

I'd say we need a different fix here. First, the question is whether there 
are any force-feedback devices, supported by USBHID force-feedback layer, 
which have a bluetooth version?

If there are none of them, we could just drop the FF initialization 
completely for now. 

On the other hand if there are such devices, just calling hid_ff_init() is 
presently not enough anyway, as the force feedback drivers for HID devices 
are currently USB-transport specific.

-- 
Jiri Kosina

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
