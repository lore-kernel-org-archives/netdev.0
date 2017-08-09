From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 0/3] Fix y2038 issues for security/keys subsystem
Date: Wed,  9 Aug 2017 10:51:29 +0800
Message-ID: <cover.1502246501.git.baolin.wang@linaro.org>
Cc: james.l.morris@oracle.com, serge@hallyn.com,
        marc.dionne@auristor.com, dan.carpenter@oracle.com,
        Jason@zx2c4.com, arnd@arndb.de, broonie@kernel.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        baolin.wang@linaro.org
To: dhowells@redhat.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 'time_t', 'timeval' and 'timespec' types are not year 2038 safe on
32 bits system, this patchset tries to fix this issues for security/keys
subsystem and net/rxrpc subsystem which is connected with security/keys
subsystem.

Baolin Wang (3):
  security: keys: Replace time_t/timespec with time64_t
  security: keys: Replace time_t with time64_t for struct
    key_preparsed_payload
  net: rxrpc: Replace time_t type with time64_t type

 include/keys/rxrpc-type.h    |   21 +++++++++++++++++++++
 include/linux/key-type.h     |    2 +-
 include/linux/key.h          |    7 ++++---
 net/rxrpc/ar-internal.h      |    2 +-
 net/rxrpc/key.c              |   22 ++++++++++++++--------
 net/rxrpc/rxkad.c            |   14 +++++++-------
 security/keys/gc.c           |   20 ++++++++++----------
 security/keys/internal.h     |    8 ++++----
 security/keys/key.c          |   27 ++++++++++-----------------
 security/keys/keyring.c      |   18 +++++++++---------
 security/keys/permission.c   |    3 +--
 security/keys/proc.c         |   20 ++++++++++----------
 security/keys/process_keys.c |    2 +-
 13 files changed, 93 insertions(+), 73 deletions(-)

-- 
1.7.9.5
