From: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Subject: Possible memory leak in function (r8712_setrttbl_cmd) not freeing
 pointer (ph2c) on error path
Date: Sun, 30 Nov 2014 19:06:20 -0600
Message-ID: <CAFZT-jJ=g9Nbzybf1tgNe4bBUi-Xt-dmtsAzoME9V-Dnf76j_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44460 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaLABGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 20:06:21 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so8605525iga.8
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 17:06:20 -0800 (PST)
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
