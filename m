From: jamal <hadi@cyberus.ca>
Subject: [PATCH][IPROUTE2] Fixup u32 pretty printing
Date: Sun, 20 Apr 2008 10:43:55 -0400
Message-ID: <1208702635.12249.48.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:58832 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbYDTOn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 10:43:59 -0400
Received: by wx-out-0506.google.com with SMTP id h31so966785wxd.4
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 07:43:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

I am going to re-send the original patch i sent (my git skills are
limited) along with two others for a total of 3. 

With these patches:

1) the default output stays as it was before and only when the user
adds a -cooked does the new pretty printing take effect. Example:

--------
hadi@lilsol:~$ tc -c filter ls dev lo parent ffff:

filter protocol ip pref 9 u32 fh 801::802 order 2050 key ht 801 bkt 0
flowid 1:16
  match IP src 10.0.0.2/32
  match IP protocol 6
  match sport 53

hadi@lilsol:~$ tc -c filter ls dev lo parent ffff:

filter protocol ip pref 9 u32 fh 801::802 order 2050 key ht 801 bkt 0
flowid 1:16
  match 0a000002/ffffffff at 12
  match 00060000/00ff0000 at 8
  match 00000035/0000ffff at 20
--------

2) A new infrastructure within u32 classifier to add more pretty
printers is added and used for raw and ipv4.

I have at least two more patches lined up, but will wait for the
application of these 3 patches or any discussion of these three first
before submitting.

cheers,
jamal

