From: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Subject: Possible memory leak in function (wil_write_file_wmi) not freeing
 pointer (wmi) on error path
Date: Thu, 27 Nov 2014 17:46:21 -0600
Message-ID: <CAFZT-jLp3M7nABh4s5pdud89TjYQhT5GjBpDY4P1_efsMRgCfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:56593 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbaK0XqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 18:46:21 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so9155806igb.7
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 15:46:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug Report: https://bugzilla.kernel.org/show_bug.cgi?id=88971
Linux Version [3.17-rc1]
Configuration: Default configuration for x86

Function (wil_write_file_wmi) in file
(drivers/net/wireless/ath/wil6210/debugfs.c) allocates pointer (wmi)
on line (536) and passes it as a parameter to function
(simple_write_to_buffer) at line (540). Function
(simple_write_to_buffer) returns on line (539) with a negative value.
This causes function (wil_write_file_wmi) to return on line (542)
without freeing pointer (wmi). Thus, causing a possible memory leak
not freeing pointer (wmi).

(wil_write_file_wmi) source code reference:
http://lxr.free-electrons.com/source/drivers/net/wireless/ath/wil6210/debugfs.c#L523
(simple_write_to_buffer) source code reference:
http://lxr.free-electrons.com/source/fs/libfs.c#L625


~Ahmed
