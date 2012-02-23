From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: iproute2: missing dynamic symbols in Android (ICS)
Date: Thu, 23 Feb 2012 11:04:00 +0100
Message-ID: <CAGm1_kuiJ9hikPQBMjt7O61juu9vFwdJJvixarzfs8HUjdsN-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, wg@grandegger.com
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59779 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab2BWKEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 05:04:20 -0500
Received: by ggnh1 with SMTP id h1so487470ggn.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 02:04:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working with Android and would like to use ip utility. Support for
this utility was added some time ago and Android provides  2.6.35
version of iproute2.

The problem I have is that symbols from ip/iplink_can.c,
ip/iplink_vlan.c etc. are missing in the final binary. I also get
following compiler warnings:

target thumb C: ip <= external/iproute2/ip/iplink_can.c
prebuilt/linux-x86/ccache/ccache
prebuilt/linux-x86/toolchain/arm-linux-androideabi-4.4.x/bin/arm-linux-androideabi-gcc
-I bionic/libc/kernel/common -I bionic/libc/kernel/arch-arm -I
external/iproute2/include -I external/iproute2/ip -I
out/target/product/beagleboard/obj/EXECUTABLES/ip_intermediates -I
dalvik/libnativehelper/include/nativehelper -isystem
system/core/include -isystem hardware/libhardware/include -isystem
hardware/libhardware_legacy/include -isystem hardware/ril/include
-isystem dalvik/libnativehelper/include -isystem
frameworks/base/include -isystem frameworks/base/opengl/include
-isystem frameworks/base/native/include -isystem external/skia/include
-isystem out/target/product/beagleboard/obj/include -isystem
bionic/libc/arch-arm/include -isystem bionic/libc/include -isystem
bionic/libstdc++/include -isystem bionic/libm/include -isystem
bionic/libm/include/arm -isystem bionic/libthread_db/include -c
-fno-exceptions -Wno-multichar -msoft-float -fpic -ffunction-sections
-fdata-sections -funwind-tables -fstack-protector -Wa,--noexecstack
-Werror=format-security -fno-short-enums -march=armv7-a
-mfloat-abi=softfp -mfpu=neon -include
system/core/include/arch/linux-arm/AndroidConfig.h -I
system/core/include/arch/linux-arm/ -Wno-psabi -mthumb-interwork
-DANDROID -fmessage-length=0 -W -Wall -Wno-unused -Winit-self
-Wpointer-arith -Werror=return-type -Werror=non-virtual-dtor
-Werror=address -Werror=sequence-point -DNDEBUG -g -Wstrict-aliasing=2
-fgcse-after-reload -frerun-cse-after-loop -frename-registers -DNDEBUG
-UDEBUG -mthumb -Os -fomit-frame-pointer -fno-strict-aliasing  -O2 -g
-W -Wall      -MD -o
out/target/product/beagleboard/obj/EXECUTABLES/ip_intermediates/iplink_can.o
external/iproute2/ip/iplink_can.c
external/iproute2/ip/iplink_can.c: In function 'can_parse_opt':
external/iproute2/ip/iplink_can.c:97: warning: unused parameter 'lu'
external/iproute2/ip/iplink_can.c: In function 'can_print_opt':
external/iproute2/ip/iplink_can.c:196: warning: unused parameter 'lu'
external/iproute2/ip/iplink_can.c: In function 'can_print_xstats':
external/iproute2/ip/iplink_can.c:260: warning: unused parameter 'lu'

This is how ip-/Android.mk looks like:

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := ip.c ipaddress.c ipaddrlabel.c iproute.c iprule.c   \
        rtm_map.c iptunnel.c ip6tunnel.c tunnel.c ipneigh.c ipntable.c \
        iplink.c ipmaddr.c ipmonitor.c ipmroute.c ipprefix.c ipxfrm.c  \
        xfrm_state.c xfrm_policy.c xfrm_monitor.c iplink_vlan.c        \
        link_veth.c link_gre.c iplink_can.c iptuntap.c

LOCAL_MODULE := ip

LOCAL_MODULE_TAGS := optional

LOCAL_SHARED_LIBRARIES := libc libm libdl

LOCAL_SHARED_LIBRARIES += libiprouteutil libnetlink

LOCAL_C_INCLUDES := $(KERNEL_HEADERS) external/iproute2/include

LOCAL_CFLAGS := -O2 -g -W -Wall

include $(BUILD_EXECUTABLE)

I tried to get help from Android Community but none answered:
https://groups.google.com/d/topic/android-building/yjV4iYnT1Zc/discussion

Any idea how can I solve this problem?

Best regards,
Yegor
