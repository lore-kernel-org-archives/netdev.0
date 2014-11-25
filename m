From: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Subject: Possible memory leak in function (r8712_setrttbl_cmd) not freeing
 pointer (ph2c) on error path
Date: Tue, 25 Nov 2014 08:24:57 -0600
Message-ID: <CAFZT-jL+pUyeVJ1c7W-d+gaC_C2ezP2fVK_HpoZuvisyEsjFSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38441 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaKYOY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 09:24:58 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so744142igb.17
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 06:24:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug Report Filed: https://bugzilla.kernel.org/show_bug.cgi?id=88881
Linux Version [3.17-rc1]
Configuration: Default configuration for x86

In function (r8712_setrttbl_cmd) file (drivers/staging/rtl8712/rtl871x_cmd.c):

Function (r8712_setrttbl_cmd) allocates the variable (ph2c) at line
732 and passes it as a parameter to function (r8712_enqueue_cmd) at
line 743. Function (r8712_setrttbl_cmd) returns (_SUCCESS) result
regardless of the result of the called function (r8712_enqueue_cmd)
which may return (_FAIL) at line 176. This failure causing the
allocated object not to be queued and hence not freed later. Thus,
causing a possible memory leak not freeing the (ph2c) pointer upon
(_FAIL) return of function (r8712_enqueue_cmd).

Source code reference for function (r8712_setrttbl_cmd):
http://lxr.free-electrons.com/source/drivers/staging/rtl8712/rtl871x_cmd.c#L725

Source code reference for function (r8712_enqueue_cmd):
http://lxr.free-electrons.com/source/drivers/staging/rtl8712/rtl871x_cmd.c#L171


~Ahmed
