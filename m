From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Tue, 9 May 2006 18:36:09 -0400
Message-ID: <200605091836.10138.flamingice@sourmilk.net>
References: <200605061401.01795.IvDoorn@gmail.com> <200605100001.20180.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:27818 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1751309AbWEIWgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:36:07 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605100001.20180.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 May 2006 18:01, Ivo van Doorn wrote:
> A user on the forums Olivier Cornu (added to the CC list) has done some
> investigation into the scanning behaviour of the dscape stack.
> Basicly the dscape stack is performing active scanning while the device is
> down, but during the active scan it is sending packets out, or at least
> attempting to do so. Besides the question if active scanning is preferred
> over passive scanning while interface is down, active scanning fails
> because the packets that should be send are being send through the regular
> xmit routines of the interface. (IFF_UP is not set for the interface)
>
> This means that besides enabling the radio which should be done in the
> driver, the stack should either bring up the interface when doing an active
> scan, or resort to passive scanning while interface is down.
>
If you can passive scan while the interface is down, I don't think it's really 
down. In adm8211, nothing can be sent or received when the interface is down. 
The radio is always off when the interface is down. Taking the interface up 
just for a scan and then taking it back down doesn't sound too good either. I 
think scans should be prohibited while the interface is down, since leaving 
the interface on isn't gonna do anything bad unless you put in the info to 
associate.

-Michael Wu
