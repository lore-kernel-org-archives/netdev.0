From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 2/5] NetEffect 10Gb RNIC Userspace
 Library: makefile generation
Date: Thu, 26 Oct 2006 19:43:59 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9ECD@venom2>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
To: openib-general@openib.org
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 2 of 5.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/src/userspace/libnes/libnes.spec.in
new/src/userspace/libnes/libnes.spec.in
--- old/src/userspace/libnes/libnes.spec.in	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/libnes.spec.in	2006-10-25
11:11:23.000000000 -0500
@@ -0,0 +1,57 @@
+
+%define ver      @VERSION@
+
+Name: libnes
+Version: 0.1
+Release: 0.%{?dist}
+Summary: NetEffect RNIC Userspace Driver
+
+Group: System Environment/Libraries
+License: GPL/BSD
+Url: http://openib.org/
+Source: http://openib.org/downloads/%{name}-%{ver}.tar.gz
+BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u}
-n)
+
+BuildRequires: libibverbs-devel
+
+%description
+libnes provides a device-specific userspace driver for NetEffect RNICs
+for use with the libibverbs library.
+
+%package devel
+Summary: Development files for the libnes driver
+Group: System Environment/Libraries
+Requires: %{name} = %{version}-%{release}
+
+%description devel
+Static version of libnes that may be linked directly to an
+application, which may be useful for debugging.
+
+%prep
+%setup -q -n %{name}-%{ver}
+
+%build
+%configure
+make %{?_smp_mflags}
+
+%install
+rm -rf $RPM_BUILD_ROOT
+%makeinstall
+# remove unpackaged files from the buildroot
+rm -f $RPM_BUILD_ROOT%{_libdir}/infiniband/*.la
+
+%clean
+rm -rf $RPM_BUILD_ROOT
+
+%files
+%defattr(-,root,root,-)
+%{_libdir}/infiniband/nes.so
+%doc AUTHORS COPYING ChangeLog README
+
+%files devel
+%defattr(-,root,root,-)
+%{_libdir}/infiniband/nes.a
+
+%changelog
+* Wed May 10 2006 nesdev <nes@neteffect.com> - 1.0
+- First development Effort
diff -ruNp old/src/userspace/libnes/Makefile.am
new/src/userspace/libnes/Makefile.am
--- old/src/userspace/libnes/Makefile.am	1969-12-31
18:00:00.000000000 -0600
+++ new/src/userspace/libnes/Makefile.am	2006-10-25
11:11:30.000000000 -0500
@@ -0,0 +1,25 @@
+
+neslibdir = $(libdir)/infiniband
+
+neslib_LTLIBRARIES = src/nes.la
+
+src_nes_la_CFLAGS = -g -Wall -D_GNU_SOURCE
+
+if HAVE_LD_VERSION_SCRIPT
+    nes_version_script = -Wl,--version-script=$(srcdir)/src/nes.map
+else
+    nes_version_script =
+endif
+
+src_nes_la_SOURCES = src/nes_umain.c src/nes_uverbs.c
+src_nes_la_LDFLAGS = -avoid-version -module \
+    $(nes_version_script)
+
+DEBIAN = debian/changelog debian/compat debian/control debian/copyright
\
+    debian/libnes1.install debian/libnes-dev.install debian/rules
+
+EXTRA_DIST = src/nes.h src/nes-abi.h \
+    src/nes.map libnes.spec.in $(DEBIAN)
+
+dist-hook: libnes.spec
+	cp libnes.spec $(distdir)
