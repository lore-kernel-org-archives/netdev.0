From: Jike Song <albcamus@gmail.com>
Subject: Re: BUG UNIX: Poison overwritten with 2.6.31-rc6-00223-g6c30c53
Date: Tue, 8 Sep 2009 12:51:38 +0800
Message-ID: <df9815e70909072151l2686231en76773418aaf9deeb@mail.gmail.com>
References: <alpine.DEB.2.00.0909072323350.3940@parag-desktop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016367d595abd88e9047309b832
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:34214 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbZIHEvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 00:51:36 -0400
In-Reply-To: <alpine.DEB.2.00.0909072323350.3940@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016367d595abd88e9047309b832
Content-Type: text/plain; charset=UTF-8

On Tue, Sep 8, 2009 at 11:56 AM, Parag Warudkar<parag.lkml@gmail.com> wrote:
>
> On Thu, Aug 27, 2009 at 4:45 PM, Jike Song<albcamus@gmail.com> wrote:
>>> hi, I hit this with vnc. Below is part of dmesg :
>
>> Still producible in 2.6.31-rc9, anybody helps?
>
> How does one go about reproducing this? You said VNC triggers this but
> what VNC version, server or client? What distro and what needs to be done
> with VNC to trigger this problem? I ask since I use VNC myself and test -git kernels
> and have not encountered this issue.
>
> Parag
>
>
Thanks for your attention,  CC netdev this time.

VNC server: tigervnc-server-0.0.91-0.11.fc11.x86_64
VNC client:  TurboVNC Viewer version 0.5 for Solaris
Distro       : Fedora 11, x86-64

I specify gnome-init in xstartup, below is my xstartup file, with this
file one only need to run vncviewer from the client to produce this
bug:

#!/bin/sh

unset LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
unset LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
unset LC_IDENTIFICATION LC_ALL LANG LANGUAGE PAGER
LANG=zh_CN.UTF-8
export LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
export LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
export LC_IDENTIFICATION LC_ALL LANG LANGUAGE PAGER
export G_FILENAME_ENCODING=@locale
XMODIFIERS="@im=SCIM"
GTK_IM_MODULE="scim"
export XMODIFIERS GTK_IM_MODULE
if type scim &> /dev/null ; then
	scim -d &
fi

vncconfig -iconic &
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
OS=`uname -s`
if [ $OS = 'Linux' ]; then
  case "$WINDOWMANAGER" in
    *gnome*)
      if [ -e /etc/SuSE-release ]; then
        PATH=$PATH:/opt/gnome/bin
        export PATH
      fi
      ;;
  esac
fi
if [ -x /etc/X11/xinit/xinitrc ]; then
  exec /etc/X11/xinit/xinitrc
fi
if [ -f /etc/X11/xinit/xinitrc ]; then
  exec sh /etc/X11/xinit/xinitrc
fi
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
xterm -geometry 1024x768 -ls -title "$VNCDESKTOP Desktop" &
gnome-init &



-- 
Thanks,
Jike

--0016367d595abd88e9047309b832
Content-Type: application/octet-stream; name=xstartup
Content-Disposition: attachment; filename=xstartup
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fzc5r4nf0

IyEvYmluL3NoCgoKIyBhZGRlZCBieSBhbGJjYW11cwp1bnNldCBMQ19DVFlQRSBMQ19OVU1FUklD
IExDX1RJTUUgTENfQ09MTEFURSBMQ19NT05FVEFSWSBMQ19NRVNTQUdFUwp1bnNldCBMQ19QQVBF
UiBMQ19OQU1FIExDX0FERFJFU1MgTENfVEVMRVBIT05FIExDX01FQVNVUkVNRU5UCnVuc2V0IExD
X0lERU5USUZJQ0FUSU9OIExDX0FMTCBMQU5HIExBTkdVQUdFIFBBR0VSCkxBTkc9emhfQ04uVVRG
LTgKZXhwb3J0IExDX0NUWVBFIExDX05VTUVSSUMgTENfVElNRSBMQ19DT0xMQVRFIExDX01PTkVU
QVJZIExDX01FU1NBR0VTCmV4cG9ydCBMQ19QQVBFUiBMQ19OQU1FIExDX0FERFJFU1MgTENfVEVM
RVBIT05FIExDX01FQVNVUkVNRU5UCmV4cG9ydCBMQ19JREVOVElGSUNBVElPTiBMQ19BTEwgTEFO
RyBMQU5HVUFHRSBQQUdFUgpleHBvcnQgR19GSUxFTkFNRV9FTkNPRElORz1AbG9jYWxlClhNT0RJ
RklFUlM9IkBpbT1TQ0lNIgpHVEtfSU1fTU9EVUxFPSJzY2ltIgpleHBvcnQgWE1PRElGSUVSUyBH
VEtfSU1fTU9EVUxFCmlmIHR5cGUgc2NpbSAmPiAvZGV2L251bGwgOyB0aGVuCglzY2ltIC1kICYK
ZmkKCnZuY2NvbmZpZyAtaWNvbmljICYKdW5zZXQgU0VTU0lPTl9NQU5BR0VSCnVuc2V0IERCVVNf
U0VTU0lPTl9CVVNfQUREUkVTUwpPUz1gdW5hbWUgLXNgCmlmIFsgJE9TID0gJ0xpbnV4JyBdOyB0
aGVuCiAgY2FzZSAiJFdJTkRPV01BTkFHRVIiIGluCiAgICAqZ25vbWUqKQogICAgICBpZiBbIC1l
IC9ldGMvU3VTRS1yZWxlYXNlIF07IHRoZW4KICAgICAgICBQQVRIPSRQQVRIOi9vcHQvZ25vbWUv
YmluCiAgICAgICAgZXhwb3J0IFBBVEgKICAgICAgZmkKICAgICAgOzsKICBlc2FjCmZpCmlmIFsg
LXggL2V0Yy9YMTEveGluaXQveGluaXRyYyBdOyB0aGVuCiAgZXhlYyAvZXRjL1gxMS94aW5pdC94
aW5pdHJjCmZpCmlmIFsgLWYgL2V0Yy9YMTEveGluaXQveGluaXRyYyBdOyB0aGVuCiAgZXhlYyBz
aCAvZXRjL1gxMS94aW5pdC94aW5pdHJjCmZpClsgLXIgJEhPTUUvLlhyZXNvdXJjZXMgXSAmJiB4
cmRiICRIT01FLy5YcmVzb3VyY2VzCnhzZXRyb290IC1zb2xpZCBncmV5Cnh0ZXJtIC1nZW9tZXRy
eSAxMDI0eDc2OCAtbHMgLXRpdGxlICIkVk5DREVTS1RPUCBEZXNrdG9wIiAmCmdub21lLWluaXQg
Jgo=
--0016367d595abd88e9047309b832--
